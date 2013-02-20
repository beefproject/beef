//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

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
	 * The panel used to select hooked browsers as proxy endpoints.
	 * TODO: Add list of hooked browsers here
	 ********************************************/
	var proxy_panel = new Ext.Panel({
		id: 'requester-proxy-zombie-'+zombie.session,
		title: 'Proxy',
		layout: 'fit',
		padding: '10 10 10 10',
                html: "<div style='font:11px tahoma,arial,helvetica,sans-serif;width:500px' ><p style='font:11px tahoma,arial,helvetica,sans-serif'>The Tunneling Proxy allows you to use a hooked browser as a proxy. Simply right-click a browser from the Hooked Browsers tree to the left and select \"Use as Proxy\".</p><p style='margin: 10 0 10 0'><img src='/ui/media/images/help/proxy.png'></p><p>The proxy runs on localhost port 6789 by default. Each request sent through the Proxy is recorded in the History panel in the Rider tab. Click a history item to view the HTTP headers and HTML source of the HTTP response.</p><p style='margin: 10 0 10 0'><img src='/ui/media/images/help/history.png'></p><p style='font:11px tahoma,arial,helvetica,sans-serif'>To manually forge an arbitrary HTTP request use the \"Forge Request\" tab from the Rider tab.</p><p style='margin: 10 0 10 0'><img src='/ui/media/images/help/forge.png'></p><p style='font:11px tahoma,arial,helvetica,sans-serif'>For more information see: <a href=\"https://github.com/beefproject/beef/wiki/Tunneling\">https://github.com/beefproject/beef/wiki/Tunneling</a></p></div>",
		listeners: {
			activate: function(proxy_panel) {
				// to do: refresh list of hooked browsers
			}
		}

	});

	/*
	 * TODO: The panel used to configure the proxy on-the-fly
	 ********************************************/
	/*
	var options_panel = new Ext.Panel({
		id: 'requester-options-zombie-'+zombie.session,
		title: 'Proxy',
		layout: 'fit'
	});
	*/
	/*
	 * The panel that displays the history of all requests performed.
	 ********************************************/
	var history_panel_store = new Ext.ux.data.PagingJsonStore({
		storeId: 'requester-history-store-zombie-'+zombie.session,
		url: '/ui/requester/history.json',
		remoteSort: false,
		autoDestroy: true,
		autoLoad: false,
		root: 'history',

		fields: ['domain', 'port', 'method', 'request_date', 'response_date','id', 'has_ran', 'path','response_status_code', 'response_status_text', 'response_port_status'],
		sortInfo: {field: 'request_date', direction: 'DESC'},
		
		baseParams: {
			nonce: Ext.get("nonce").dom.value,
			zombie_session: zombie.session
		}
	});

	var req_pagesize = 30;

	var history_panel_bbar = new Ext.PagingToolbar({
		pageSize: req_pagesize,
		store: history_panel_store,
		displayInfo: true,
		displayMsg: 'Displaying history {0} - {1} of {2}',
		emptyMsg: 'No history to display'
	});

    /*
     * Uncomment it when we'll add a contextMenu (right click on a row) in the history grid
     */
//    var history_panel_context_menu = new Ext.menu.Menu({
//        items: [{
//            id: 'do-something',
//            text: 'Do something'
//        }],
//        listeners: {
//            itemclick: function(item) {
//                switch (item.id) {
//                    case 'do-something':
//                        break;
//                }
//            }
//        }
//    });

	var history_panel_grid = new Ext.grid.GridPanel({
		id: 'requester-history-grid-zombie-'+zombie.session,
		store: history_panel_store,
		bbar: history_panel_bbar,
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
			{header: 'Id', width: 10, sortable: true, dataIndex: 'id', hidden:true},
			{header: 'Domain', sortable: true, dataIndex: 'domain', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Port', width: 30, sortable: true, dataIndex: 'port', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Method', width: 30, sortable: true, dataIndex: 'method', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Path', sortable: true, dataIndex: 'path', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Res Code', width: 35, sortable: true, dataIndex: 'response_status_code', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Res Text', width: 50, sortable: true, dataIndex: 'response_status_text', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Port Status', width: 40, sortable: true, dataIndex: 'response_port_status', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Processed', width: 50, sortable: true, dataIndex: 'has_ran', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Req Date', width: 50, sortable: true, dataIndex: 'request_date', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Res Date', width: 50, sortable: true, dataIndex: 'response_date', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}

		],
		
		listeners: {
			rowclick: function(grid, rowIndex) {
				var tab_panel = Ext.getCmp('zombie-requester-tab-zombie-'+zombie.session);
				var r = grid.getStore().getAt(rowIndex).data;
				
				if(r.has_ran != "complete") {
					commands_statusbar.update_fail("Response for this request has not been received yet.");
					return;
				}
				
				if(!tab_panel.get('requester-response-'+r.id)) {
					genResultTab(r, zombie, commands_statusbar);
				}
			},
			afterrender: function(datagrid) {
				datagrid.store.reload({params:{start:0,limit:req_pagesize, sort: "date", dir:"DESC"}});
			}

            //  Uncomment it when we'll add a contextMenu (right click on a row) in the history grid
//            ,rowcontextmenu: function(grid, rowIndex, event){
//                 event.stopEvent();
//
//                 history_panel_context_menu.showAt(event.xy);
//                 history_panel_context_menu.rowIndex = rowIndex;
//                 history_panel_context_menu.dbIndex = getHttpDbId(grid, rowIndex);
//            }
		}
	});
	
	
	var history_panel = new Ext.Panel({
		id: 'requester-history-panel-zombie-'+zombie.session,
		title: 'History',
		items:[history_panel_grid],
		layout: 'fit',
		
		listeners: {
			activate: function(history_panel) {
				history_panel.items.items[0].store.reload({params:{url:'/ui/requester/history.json'}});
			}
		}
	});

	// Return the extension_requester_http table row ID given a grid row index
	function getHttpDbId(grid, rowIndex){
		var row = grid.getStore().getAt(rowIndex).data;
		var result = null;
		if(row != null){
			result = row.id;
		}
		return result;
	}
	
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
			if (zombie.domain) {
				value = "GET /demos/secret_page.html HTTP/1.1\n";
				value += "Host: "+zombie.domain+":"+zombie.port+"\n";
			} else value = "GET / HTTP/1.1\nHost: \n";
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
				
				var tab_result_response_headers = new Ext.Panel({
					title: 'Response Headers',
					border: false,
					collapsed: true,
					layout: 'fit',
					padding: '5px 5px 5px 5px',
					items:[new Ext.form.TextArea({id: 'requester-response-res-headers-'+request.id, value: xhr.result.response_headers + "\n"})]
				});

				var tab_result_response_body = new Ext.Panel({
					title: 'Response Body',
					border: false,
					collapsed: false,
					layout: 'fit',
					padding: '5px 5px 5px 5px',
					items:[new Ext.form.TextArea({id: 'requester-response-res-body-'+request.id, value: xhr.result.response + "\n"})]
				});

				var tab_result_request = new Ext.Panel({
					title: 'Request',
					border: false,
					collapsed: true,
					layout: 'fit',
					padding: '5px 5px 5px 5px',
					items:[new Ext.form.TextArea({id: 'requester-response-req-'+request.id, value: xhr.result.request})]
				});
		
				var tab_result_accordion = new Ext.Panel({
					id: 'requester-response-'+request.id,
					title: $jEncoder.encoder.encodeForHTML(request.path),
					split: true,
					border: false,
					layout:'accordion',
					closable: true,
					items:[tab_result_request, tab_result_response_headers, tab_result_response_body]
				});
		
				tab_panel.add(tab_result_accordion);
				tab_panel.activate(tab_result_accordion.id);
				
				bar.update_sent("Displaying response.");
			},
			
			failure: function() {
				bar.update_fail("Error! Could not retrieve the response.");
			}
		});
	};


	ZombieTab_Requester.superclass.constructor.call(this, {
		id: 'zombie-requester-tab-zombie-'+zombie.session,
		title: 'Rider',
		activeTab: 0,
		viewConfig: {
			forceFit: true,
			type: 'fit'
		},
		
        items: [history_panel, requests_panel, proxy_panel],
		
		bbar: commands_statusbar,
		
		listeners: {
			afterrender : function(){
				genRawRequestPanel(zombie, commands_statusbar);
			}
		}
	});
	
};

Ext.extend(ZombieTab_Requester, Ext.TabPanel, {});
