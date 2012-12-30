//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

HooksTab = function() {

	/*
	 * The panel used to configure the hook.
	 ********************************************/
	var hooks_panel = new Ext.FormPanel({
		title: 'Hooks',
		id: 'hooks-panel',
		hideLabels : false,
		border: false,
		padding: '3px 5px 0 5px',

		items:[{
			fieldLabel: 'Text',
			xtype: 'textarea',
			id: 'inputText',
			name: 'inputText',
			width: '100%',
			height: '40%',
			allowBlank: true
		},{
			fieldLabel: 'Result',
			xtype: 'textarea',
			id: 'resultText',
			name: 'resultText',
			width: '100%',
			height: '40%',
			allowBlank: true
		}],

		buttons: [{
			text: 'Add Hook',
			handler: function() {
				var form = Ext.getCmp('hooks-panel').getForm();
				var form_values = form.getValues();
				var input_text = form_values['inputText'];
				var result="";
				form.setValues({resultText: result});
			}
		},{
			text: 'Delete Hook',
			handler: function() {
				var form = Ext.getCmp('hooks-panel').getForm();
				var form_values = form.getValues();
				var input_text = form_values['inputText'];
				var result="";
				form.setValues({resultText: result});
			}
		}]

	});

	HooksTab.superclass.constructor.call(this, {
		region: 'center',
		items: [hooks_panel],
		autoScroll: true,
		border: false
	});

};

Ext.extend(HooksTab,Ext.Panel, {}); 
