//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

var zombie_execute_button_text = 'Execute'
var zombie_reexecute_button_text = 'Re-execute'
var re_execute_command_title = 'Re-execute command'

/**
 * Generates fields for the form used to send command modules.
 *
 * @param: {Object} the form to generate the field in.
 * @param: {String/Object} the field name or it's definition as an object.
 * @param: {String} the value that field should have.
 * @param: {Boolean} set to true if you want the field to be disabled.
 * @param: {Object} the targeted Zombie.
 */
function generate_form_input_field(form, input, value, disabled, zombie) {
	var input_field = null;
	var input_def = null;
			
	if (!input['ui_label']) input['ui_label'] = input['name'];
	if (!input['type']) input['type'] = 'textfield';
	if (!input['value']) input['value'] = '';

	input_def = { 
		id: 'form-zombie-'+zombie.session+'-field-'+input['name'], 
		name: 'txt_'+input['name'], 
		fieldLabel: input['ui_label'],
        anchor:'70%',
		allowBlank: false, 
		value: input['value']
	};
		
	// create the input field object based upon the type supplied
	switch(input['type'].toLowerCase()) {
		case 'textfield':
			input_field = new Ext.form.TextField(input_def);
			break;
		case 'textarea':
			input_field = new Ext.form.TextArea(input_def);
			break;
		case 'hidden':
			input_field = new Ext.form.Hidden(input_def);
			break;
		case 'label':
			input_def['fieldLabel'] = ''
			input_def['html'] = input['html'];
			input_field = new Ext.form.Label(input_def);
			break;
		case 'checkbox':
			input_def['name'] = 'chk_' + input['name'];
			input_field = new Ext.form.Checkbox(input_def);
			break;
		case 'checkboxgroup':
			input_def['name'] = 'chkg_' + input['name'];
			input_def['items'] = input['items'];
			input_field = new Ext.form.CheckboxGroup(input_def);
			break;
   		case 'combobox':
            input_def['name'] = 'com_' + input['name'];
			input_def['triggerAction'] = 'all';

            if(input.reloadOnChange || input.defaultPayload != null) { // defined in msfcommand.rb
				Ext.getCmp("payload-panel").show(); // initially the panel will be empty so it may appear still hidden
				input_def['listeners'] = {
                    // update the payload options when one of them is selected
					'select': function(combo, value) {
						get_dynamic_payload_details(combo.getValue(), zombie);
                    },
                    // set the default payload value as defined in defaultPayload
                    'afterrender': function(combo){
                        combo.setValue(input.defaultPayload);
                        get_dynamic_payload_details(combo.getValue(),zombie);
                    }
		    	};
			}


			// create store to contain options for the combo box
			input_def['store']  = new Ext.data.ArrayStore( {
				fields: input['store_fields'],
				data: input['store_data']
			});

			input_field = new Ext.form.ComboBox(input_def);
								
			break;
		default:
			input_field = new Ext.form.TextField(input_def);
			break;
	}
		
	// add the properties for the input element, for example: widths, default values and the html lables
	for(definition in input) {
		if( (typeof input[definition] == 'string') && (definition != 'type') && (definition != 'name')) {
			input_field[definition] = input[definition];
		}
	}

	if(value) input_field.setValue(value);
	if(disabled) input_field.setDisabled(true);
		
	form.add(input_field);
		
};

function get_dynamic_payload_details(payload, zombie) {
    modid = Ext.getCmp('form-zombie-' + zombie.session + '-field-mod_id').value;
	Ext.Ajax.request({
		loadMask: true,
        url: '<%= @base_path %>/modules/select/commandmodule.json',
        method: 'POST',
		params: 'command_module_id=' + modid  + '&' + 'payload_name=' + payload,
		success: function(resp) {
			var module = Ext.decode(resp.responseText);
			module = module.command_modules[1][0];
			Ext.getCmp("payload-panel").removeAll(); // clear the panel contents
			Ext.each(module.data , function(input){
				// generate each of the payload input options
				generate_form_input_field(Ext.getCmp("payload-panel"), input, null, false, zombie);
			});
			
			Ext.getCmp("payload-panel").doLayout();
		}
	})
}

/**
 * Generate a panel for an command module that already has been executed.
 * 
 * @param: {Object} the Panel in the UI to generate the form into.
 * @param: {Integer} the command id to generate the panel for.
 * @param: {Object} the targeted Zombie.
 * @param: {Object} the status bar.
 */
function genExistingExploitPanel(panel, command_id, zombie, sb) {
	if(typeof panel != 'object') {
		Ext.beef.msg('Bad!', 'Incorrect panel chosen.');
		return;
	}
	
	sb.showBusy(); // status bar update
	panel.removeAll();
	
	Ext.Ajax.request({
		url: '<%= @base_path %>/modules/select/command.json',
		method: 'POST',
		params: 'command_id=' + command_id,
		loadMask: true,
		success: function(resp) {
			var xhr = Ext.decode(resp.responseText);
			
			if(!xhr || !xhr.definition) {
				Ext.beef.msg('Error!', 'We could not retrieve the definition of that command module...');
				return;
			}
			
			var form = new Ext.form.FormPanel({
				url: '<%= @base_path %>/modules/commandmodule/reexecute',
				id: 'form-command-module-zombie-'+zombie.session,
				border: false,
				labelWidth: 75,
				defaultType: 'textfield',
				title: re_execute_command_title,
				bodyStyle: 'padding: 5px;',
				
				items: [new Ext.form.Hidden({name: 'command_id', value: command_id})],
				
				buttons:[{
					text: zombie_reexecute_button_text,	
					handler: function()	{
						var form = Ext.getCmp('form-command-module-zombie-'+zombie.session);
						if(!form || !form.getForm().isValid()) return;
						
						sb.update_sending('Sending commands to ' + zombie.ip + '...'); // status bar update
						
						var command_module_form = form.getForm(); // form to be submitted when execute button is pressed on an command module tab
						command_module_form.submit({
							params: {  // insert the nonce with the form
									nonce: Ext.get ("nonce").dom.value
							},
							success: function() {
								sb.update_sent("Commands sent to zombie " + zombie.ip); // status bar update
							},
							failure: function() {
								sb.update_fail("Error!"); // status bar update
							}
						});
					}
				}]
			});
			
			Ext.each(xhr.definition.Data, function(input) {
				var value = null;
				
				if(typeof input == 'string') {
					value = xhr.data[input];
				}
				
				if(typeof input == 'object' && typeof input[0] == 'object') {
					value = xhr.data[input[0]['name']]
				}
				
				generate_form_input_field(form, input, value, false, zombie);
			});
			
			var grid_store = new Ext.data.JsonStore({
				url: '<%= @base_path %>/modules/select/command_results.json?command_id='+command_id,
				storeId: 'command-results-store-zombie-'+zombie.session,
		        root: 'results',
				remoteSort: false,
				autoDestroy: true,
		        fields: [
					{name: 'date', type: 'date', dateFormat: 'timestamp'},
					{name: 'data'}
				]
			});
			
			Ext.TaskMgr.start({
			    run: function(task) {
					var grid = Ext.getCmp('command-results-grid-zombie-'+zombie.session);
					//here we have to check for the existance of the grid before reloading
					//because we do not want to reload the store if the tab has been closed.
					if(grid_store && grid) {
						grid_store.reload();
					}
				},
			    interval: 4000
			});
			
			var grid = new Ext.grid.GridPanel({
				id: 'command-results-grid-zombie-'+zombie.session,
				store: grid_store,
				border: false,
				hideHeaders: true,
				title: 'Command results',
				
				viewConfig: {
					forceFit:true
				},

			// render command responses
		        columns:[new Ext.grid.RowNumberer({width: 20}), {
			            dataIndex: 'date',
			            sortable: false,
						renderer: function(value, p, record) {
							html = String.format("<div style='color:#385F95;text-align:right;'>{0}</div>", value);
							html += '<p>';
							for(index in record.data.data) {
								result = record.data.data[index];
								index  = index.toString().replace('_', ' ');

								// Check for a base64 encoded image
								var header = "image=data:image/(jpg|png);base64,";
								var re = new RegExp(header, "");
								if (result.match(re)) {

									// Render the image
									try {
										var img = result.replace(/[\r\n]/g, '');
										base64_data = window.atob(img.replace(re, ''));
										html += String.format('<img src="{0}" /><br>', img.replace(/^image=/, ''));
									} catch(e) {
										console.log("Received invalid base64 encoded image string: "+e.toString());
										html += String.format('<b>{0}</b>: {1}<br>', index, result);
									}

								// output escape everything else, but allow the <br> tag for better rendering.
								} else {
									html += String.format('<b>{0}</b>: {1}<br>', index, $jEncoder.encoder.encodeForHTML(result).replace(/&lt;br&gt;/g,'<br>'));
								}
							}

							html += '</p>';
							return html;
						}
		        	}]
		    });

			grid.store.load();

			var accordion = new Ext.Panel({
				id: 'command-results-accordion-zombie-'+zombie.session,
				layout:'accordion',
				border: false,
				items: [grid, form]
			});
				
			panel.add(accordion);
			panel.doLayout();
			
			sb.update_ready(); // status bar update
		}
	});
};

/**
 * Generate a panel for an command module.
 * 
 * @param: {Object} the Panel in the UI to generate the form into.
 * @param: {String} the path to the command module file in the framework.
 * @param: {String} the name of the command module.
 * @param: {Object} the targeted Zombie.
 * @param: {Object} the status bar.
 */
function genNewExploitPanel(panel, command_module_id, command_module_name, zombie, sb) {
	if(typeof panel != 'object') {
		Ext.beef.msg('Bad!', 'Incorrect panel chosen.');
		return;
	}
	
	var xgrid = Ext.getCmp('command-module-grid-zombie-'+zombie.session);
	var sb = Ext.getCmp('commands-bbar-zombie-'+zombie.session);
    panel.removeAll();
	if(command_module_name == 'some special command module') {
		//HERE we will develop specific panels for the command modules that require it.
	} else {
		Ext.Ajax.request({
			loadMask: true,
			url: '<%= @base_path %>/modules/select/commandmodule.json',
			method: 'POST',
			params: 'command_module_id=' + command_module_id,
			success: function(resp) {
				var module = Ext.decode(resp.responseText);
				
				if(!module) {
					Ext.beef.msg('Error!', 'We could not retrieve the definition of that command_module...');
					return;
				}

				var submiturl = '<%= @base_path %>/modules/commandmodule/new';
				if(module.dynamic){
					submiturl = '<%= @base_path %>/modules/commandmodule/dynamicnew';
				}
				
				module = module.command_modules[1];

                var form = new Ext.form.FormPanel({
					url: submiturl,
					
					id: 'form-command-module-zombie-'+zombie.session,
					border: false,
					labelWidth: 75,
					defaultType: 'textfield',
					title: module.Name,
					autoScroll: true,
					bodyStyle: 'padding: 5px;',
					
					items: [
						new Ext.form.Hidden({name: 'zombie_session', value: zombie.session}),
						new Ext.form.Hidden({name: 'command_module_id', value: command_module_id}),
						new Ext.form.DisplayField({
							name: 'command_module_description',
							fieldLabel: 'Description',
							fieldClass: 'command-module-panel-description',
							value: module.Description
							})
					],
					
					buttons:[{
						text: zombie_execute_button_text,	
						handler: function()	{
							var form = Ext.getCmp('form-command-module-zombie-'+zombie.session), command_module_params = new Array();
														
							if(!form || !form.getForm().isValid()) {
								sb.update_fail("Please complete all input fields!"); // status bar update
								return;
							}
							
							sb.update_sending('Sending commands to ' + zombie.ip + '...'); // status bar update

							var command_module_form = form.getForm();  // form to be submitted when execute button is pressed on an command module tab
							
							command_module_form.submit({
								params: {  // insert the nonce with the form
										nonce: Ext.get ("nonce").dom.value
								},
								success: function() {
									xgrid.i = 0;
									xgrid.store.reload({  //reload the command module grid
										params: {  // insert the nonce with the request to reload the grid
											nonce: Ext.get ("nonce").dom.value
								    	}
									});
									sb.update_sent("Commands sent to zombie " + zombie.ip); // status bar update
								},
								failure: function() {
									sb.update_fail("Error!"); // status bar update
								}
							});
						}
					}]
				});
				
				// create the panel and hide it 
				var payload_panel = new Ext.Panel({  
					id: 'payload-panel',  // used with Ext.GetCmp('payload-panel')
				    bodyStyle: 'padding:10px;', // we can assign styles to the main div  
						layout : 'form',
					bodyBorder: false,
				    height: 200,  
					hidden: true,
				    border: false //we can remove the border of the panel
				});
				
				Ext.each(module.Data, function(input){
					generate_form_input_field(form, input, null, false, zombie)}
				);
				
				form.add(payload_panel);
				panel.add(form);
				panel.doLayout();
                // hide the load mask after rendering of the config panel is done
                panel.configLoadMask.hide();
			}
		});
	}
};
