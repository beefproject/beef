//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  $j.unblockUI();
  beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=command sent');
});

