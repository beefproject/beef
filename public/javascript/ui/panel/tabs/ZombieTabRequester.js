/*
 * The request Tab panel for the selected zombie.
 * Loaded in /ui/panel/index.html
 */
ZombieTab_Requester = function(zombie) {
	
	// The status bar.
	var commands_statusbar = new Beef_StatusBar('requester-bbar-zombie-'+zombie.session);
	
	
	/*
	 * The panel used to forge raw HTTP requests.
	 ********************************************/
	var requests_panel = new Ext.Panel({
		id: 'requester-forge-requests-zombie-'+zombie.session,
		title: 'Forge Request',
		layout: 'fit'
	});
	
	
	/*
	 * The panel that displays the history of all requests performed.
	 ********************************************/
	var history_panel_store = new Ext.data.JsonStore({
		storeId: 'requester-history-store-zombie-'+zombie.session,
		url: '/ui/requester/history.json',
		remoteSort: false,
		autoDestroy: true,
		root: 'history',
		
		fields: ['domain', 'date', 'id', 'has_ran', 'path'],
		sortInfo: {field: 'date', direction: 'DESC'},
		
		baseParams: {
			nonce: Ext.get("nonce").dom.value,
			zombie_session: zombie.session
		}
	});
	
	var history_panel_grid = new Ext.grid.GridPanel({
		id: 'requester-history-grid-zombie-'+zombie.session,
		store: history_panel_store,
		border: false,
		loadMask: {msg:'Loading History...'},
		
		viewConfig: {
			forceFit:true
		},
		
		view: new Ext.grid.GridView({
			forceFit: true,
			emptyText: "No History",
			enableRowBody:true
		}),
		
		columns: [
			{header: 'id', width: 10, sortable: true, dataIndex: 'id', hidden: true},
			{header: 'domain', sortable: true, dataIndex: 'domain'},
			{header: 'path', sortable: true, dataIndex: 'path'},
			{header: 'response', width: 20, sortable: true, dataIndex: 'has_ran'},
			{header: 'date', width: 50, sortable: true, dataIndex: 'date'}
		],
		
		listeners: {
			rowclick: function(grid, rowIndex) {
				var tab_panel = Ext.getCmp('zombie-requester-tab-zombie-'+zombie.session);
				var r = grid.getStore().getAt(rowIndex).data;
				
				if(!r.has_ran) {
					commands_statusbar.update_fail("Response for this request has not been received yet.");
					return;
				}
				
				if(!tab_panel.get('requester-response-'+r.id)) {
					genResultTab(r, zombie, commands_statusbar);
				}
			}
		}
	});
	
	
	var history_panel = new Ext.Panel({
		id: 'requester-history-panel-zombie-'+zombie.session,
		title: 'History',
		items:[history_panel_grid],
		layout: 'fit',
		
		listeners: {
			activate: function(history_panel) {
				history_panel.items.items[0].store.reload();
			}
		}
	});
	
	// Function generating the requests panel to send raw requests
	//-------------------------------------------------------------
	function genRawRequestPanel(zombie, bar, value) {
		var form = new Ext.FormPanel({
			title: 'Forge Raw HTTP Request',
			id: 'requester-request-form-zombie'+zombie.session,
			url: '/ui/requester/send',
			hideLabels : true,
			border: false,
			padding: '3px 5px 0 5px',
			
			items:[{
				xtype: 'textarea',
				id: 'raw-request-zombie-'+zombie.session,
				name: 'raw_request',
				width: '100%',
				height: '100%',
				allowBlank: false
			}],
			
			buttons: [{
				text: 'Send',
				handler: function() {
					var form = Ext.getCmp('requester-request-form-zombie'+zombie.session).getForm();
					
					bar.update_sending('Sending request to ' + zombie.ip + '...');
					
					form.submit({
						params: {
							nonce: Ext.get("nonce").dom.value,//insert the nonce with the form
							zombie_session: zombie.session
						},
						success: function() {
							bar.update_sent("Request sent to hooked browser " + zombie.ip);
						},
						failure: function() {
							bar.update_fail("Error! Invalid http request.");
						}
					});
				}
			}]
		});
		
		if(!value) {
			value = "GET /demos/secret_page.html HTTP/1.1\n";
			
			if(zombie.domain) {
				value += "Host: "+zombie.domain.split(':')[0]+"\n";
			} else {
				value += "Host: \n";
			}
		}
		
		form.get('raw-request-zombie-'+zombie.session).value = value;
		
		panel = Ext.getCmp('requester-forge-requests-zombie-'+zombie.session);
		panel.setTitle('Forge Request');
		panel.add(form);
	};
	
	// Function generating the panel that shows the results of a request
	// This function is called when the user clicks on a row in the grid
	// showing the results in the history.
	//------------------------------------------------------------------
	function genResultTab(request, zombie, bar) {
		var tab_panel = Ext.getCmp('zombie-requester-tab-zombie-'+zombie.session);
		
		bar.update_sending('Getting response...');
		
		Ext.Ajax.request({
			url: '/ui/requester/response.json',
			loadMask: true,
			
			params: {
				nonce: Ext.get("nonce").dom.value,
				http_id: request.id
			},
			
			success: function(response) {
				var xhr = Ext.decode(response.responseText);
				
				var tab_result_response = new Ext.Panel({
					title: 'Reponse',
					border: false,
					layout: 'fit',
					padding: '5px 5px 5px 5px',
					items:[new Ext.form.TextArea({id: 'requester-response-res-'+request.id, value: xhr.result.response})]
				});
		
				var tab_result_request = new Ext.Panel({
					title: 'Request',
					border: false,
					layout: 'fit',
					padding: '5px 5px 5px 5px',
					items:[new Ext.form.TextArea({id: 'requester-response-req-'+request.id, value: xhr.result.request})]
				});
		
				var tab_result_accordion = new Ext.Panel({
					id: 'requester-response-'+request.id,
					title: request.path,
					split: true,
					border: false,
					layout:'accordion',
					closable: true,
					items:[tab_result_response, tab_result_request]
				});
		
				tab_panel.add(tab_result_accordion);
				tab_panel.activate(tab_result_accordion.id);
				
				bar.update_sent("Displaying response.");
			},
			
			failure: function() {
				bar.update_fail("Error! Could you retrieve the response.");
			}
		});
	};
	
	
	ZombieTab_Requester.superclass.constructor.call(this, {
		id: 'zombie-requester-tab-zombie-'+zombie.session,
		title: 'Requester',
		activeTab: 0,
		viewConfig: {
			forceFit: true,
			type: 'fit'
		},
		
        items: [history_panel, requests_panel],
		
		bbar: commands_statusbar,
		
		listeners: {
			afterrender : function(){
				genRawRequestPanel(zombie, commands_statusbar);
			}
		}
	});
	
};

Ext.extend(ZombieTab_Requester, Ext.TabPanel, {});