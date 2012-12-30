//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

Ext.onReady(function() {

	submitAuthForm = function() {

		login_mask.show();
		login_form.getForm().submit({

			success: function() {
				window.location.href = '/ui/panel'
			}, 
			failure: function() {
				if(Ext.get('loginError') == null) {
					Ext.DomHelper.insertAfter('loadingError', {id:'loginError', html: '<b>ERROR</b>: invalid username or password'});
				}
				login_mask.hide();
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
			id: 'loginButton',
			handler: function() {
				submitAuthForm();
			}
		}]
	});

	var login_mask = new Ext.LoadMask(Ext.getBody(), {msg:"Authenticating to BeEF..."});
	login_form.render('centered');
	Ext.DomHelper.append('login_form', {tag: 'div', id: 'loadingError'});
	document.getElementById('user').focus();

});
