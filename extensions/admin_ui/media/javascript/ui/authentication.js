Ext.onReady(function() {
	
	var bd = Ext.getBody();
	
	submitAuthForm = function() {	
		login_form.getForm().submit({
			waitMsg: 'Logging in ...',
			success: function() {
				window.location.href = '/ui/panel'
			}, 
			failure: function() {
				Ext.MessageBox.alert('Message', 'Error with username or password')
			}
		});
	}


	var login_form = new Ext.form.FormPanel({
      	
		url: 'authentication/login',
		formId: 'login_form',
		labelWidth: 125,
      	frame: true,
      	title: 'Authentication',
      	bodyStyle:'padding:5px 5px 0',
      	width: 350,
      	
		defaults: {
        	width: 175,
        	inputType: 'password'
      	},

      	defaultType: 'textfield',
      	
		items: [{
        		fieldLabel: 'Username',
        		name: 'username-cfrm',
				inputType: 'textfield',
        		id: 'user',
			listeners: {
				specialkey: function(field,e) {
					if (e.getKey() == e.ENTER) {
						submitAuthForm();
					}
				}
			}
      		},{
        		fieldLabel: 'Password',
        		name: 'password-cfrm',
        		inputType: 'password',
        		id: 'pass',
			listeners: {
				specialkey: function(field,e) {
					if (e.getKey() == e.ENTER) {
						submitAuthForm();
					}
				}
			}
      		}],
		
		buttons: [{
			text: 'Login',
			handler: function()	{ 
				submitAuthForm();
			}
		}]
	});
		
	login_form.render('centered');
	document.getElementById('user').focus();
	
});
