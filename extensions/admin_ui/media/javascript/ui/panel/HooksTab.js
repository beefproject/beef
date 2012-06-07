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
