//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=sent unhook request");

	// remove script tag(s)
	try {
		var scripts = document.getElementsByTagName("script");
		for (var i=0; i<scripts.length; i++) {
			if (scripts[i].src.match(/https?:\/\/[^\/]+\/hook\.js/)) {
				scripts[i].parentNode.removeChild(scripts[i]);
			}
		}
	} catch (e) { }

	// attempt to clean up DOM
	try {
		delete beef;
		delete BEEFHOOK;
		beef_init=null;
		BeefJS=null;
	} catch (e) { }

});

