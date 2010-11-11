Ext.onReady(function() {
	
	var bd = Ext.getBody();

	// xntrik 9/7/10 this is the functionality to try and submit the form
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


	var login_form = new Ext.FormPanel({
      	
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
			listeners: { // xntrik 9/7/10 added this listener so form submits on enter
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
			listeners: { // xntrik 9/7/10 added this listener so form submits on enter
				specialkey: function(field,e) {
					if (e.getKey() == e.ENTER) {
						submitAuthForm();
					}
				}
			}
      		}],
		
		buttons: [{
			text: 'Login',
			handler: function()	{ // xntrik 9/7/10 removed the logic here, placed
							//in function above and added here
				submitAuthForm();
			}
		}]
	});
		
	login_form.render('centered');
	document.getElementById('user').focus(); //xntrik 27/7/10 - this doesn't throw warnings now
	
});
