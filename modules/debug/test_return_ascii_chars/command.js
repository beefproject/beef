//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    var str = '';
    for (var i=32; i<=127;i++) str += String.fromCharCode(i);

    beef.net.send("<%= @command_url %>", <%= @command_id %>, str, beef.are.status_success());
    //return [beef.are.status_success(), str];
    test_return_ascii_chars_mod_output = [beef.are.status_success(), str];
});

