//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

DoLogout = function() {
	
	var button = Ext.get('do-logout-menu');
	
	after_logout = function() {
		// will redirect the UA to the login
		window.location.href = '<%= @base_path %>/panel'
	}
	
	button.on('click', function(){
		Ext.Ajax.request({
			url: '<%= @base_path %>/authentication/logout',
			method: 'POST',
		    params: 'nonce=' + Ext.get("nonce").dom.value,
			success: after_logout,
			failure: after_logout
		});
		
	})
};