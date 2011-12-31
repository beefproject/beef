//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
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
