//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	try {
		var msg = "<%= @msg.gsub(/"/, '\\"') %>";
		beef.debug(msg);
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=called the beef.debug() function. Check the developer console for your debug message.');
	} catch(e) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=something went wrong&error='+e.message);
	}

});
