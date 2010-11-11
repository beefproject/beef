DoLogout = function() {
	
	var button = Ext.get('do-logout-menu');
	
	after_logout = function() {
		// will redirect the UA to the login
		window.location.href = '/ui/panel'		
	}
	
	button.on('click', function(){
		Ext.Ajax.request({
			url: '/ui/authentication/logout',
			method: 'POST',
		    params: 'nonce=' + Ext.get("nonce").dom.value,
			success: after_logout,
			failure: after_logout
		});
		
	})
};