//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    var repeat_value = "<%= @repeat_string %>";
    var iterations = <%= @repeat %>;
    var str = "";

    for (var i = 0; i < iterations; i++) {
        str += repeat_value;
    }
    beef.net.send("<%= @command_url %>", <%= @command_id %>, str, beef.are.status_success());
    //return [beef.are.status_success(), str];
    test_return_long_string_mod_output = [beef.are.status_unknown(), str];
});

