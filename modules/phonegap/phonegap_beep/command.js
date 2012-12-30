//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// make the phone beep
//
beef.execute(function() {
    navigator.notification.beep(1);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'Beeped');
});
