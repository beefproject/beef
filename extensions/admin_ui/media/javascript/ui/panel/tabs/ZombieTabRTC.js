//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The RTC tab panel for the selected zombie browser.
 * Loaded in /ui/panel/index.html
 */
ZombieTab_Rtc = function(zombie) {
  var zombie_id = beefwui.get_hb_id(zombie.session);
	
	// The status bar.
	var commands_statusbar = new Beef_StatusBar('network-bbar-zombie-'+zombie.session);
	// RESTful API token
	var token = beefwui.get_rest_token();

	/*
	 * The panel that displays all identified network services grouped by host
	 ********************************************/
	var rtc_events_panel_store = new Ext.ux.data.PagingJsonStore({
		storeId: 'rtc-events-store-zombie-'+zombie.session,
		proxy: new Ext.data.HttpProxy({
			url: '/api/webrtc/events/'+zombie_id+'?token='+token,
			method: 'GET'
		}),
		remoteSort: false,
		autoDestroy: true,
		autoLoad: false,
		root: 'events',
		fields: ['id', 'hb_id', 'target_id', 'status', 'created_at', 'updated_at'],
		sortInfo: {field: 'id', direction: 'ASC'}
	});

	var req_pagesize = 50;

	var rtc_events_panel_bbar = new Ext.PagingToolbar({
		pageSize: req_pagesize,
		store: rtc_events_panel_store,
		displayInfo: true,
		displayMsg: 'Displaying RTC events {0} - {1} of {2}',
		emptyMsg: 'No events to display'
	});

	var rtc_events_panel_grid = new Ext.grid.GridPanel({
		id: 'rtc-events-grid-zombie-'+zombie.session,
		store: rtc_events_panel_store,
		bbar: rtc_events_panel_bbar,
		border: false,
		loadMask: {msg:'Loading events...'},
		
		viewConfig: {
			forceFit: true
		},
		
		view: new Ext.grid.GridView({
			forceFit: true,
			emptyText: "No events",
			enableRowBody:true
		}),
		
		columns: [
			{header: 'Id', width: 5, sortable: true, dataIndex: 'id', hidden:true},
      {header: 'From', width: 10, sortable: true, dataIndex: 'hb_id', hidden:true},
      {header: 'Peer', width: 10, sortable: true, dataIndex: 'target_id', renderer: function(value){
              if (value === zombie_id) {
                return $jEncoder.encoder.encodeForHTML(value) + " (selected)";
              } else {
                // return $jEncoder.encoder.encodeForHTML(value) + " <img src='/ui/media/images/icons/chrome.png' style='padding-top:3px;' width='13px' height='13px'/> (" + beefwui.get_info_from_id(value) + ")";
                return $jEncoder.encoder.encodeForHTML(value) + " (" + beefwui.get_info_from_id(value)['ip'] + ")";
              }
      }},
			{header: 'Status', width: 20, sortable: true, dataIndex: 'status', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Created At', width: 10, sortable: true, dataIndex: 'created_at', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Updated At', width: 10, sortable: true, dataIndex: 'updated_at', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}
		],

    listeners: {
      contextmenu: function(e, element, options) {
        e.preventDefault();
      },
      containercontextmenu: function(view, e) {
        e.preventDefault();
      },
      rowcontextmenu: function(grid, rowIndex, e) {
        e.preventDefault();
				grid.getSelectionModel().selectRow(rowIndex);
				if (!!grid.rowCtxMenu) {
					grid.rowCtxMenu.destroy();
				}
				var record = grid.selModel.getSelected();
        if (record.json.status==="Connected") {
          grid.rowCtxMenu = new Ext.menu.Menu({
            items: [
              {
                text: "Command Peer to Stealth",
                handler: function() {
                  if (zombie_id === record.json.hb_id) {
                    var url = "/api/webrtc/msg?token=" + beefwui.get_rest_token();
                    Ext.Ajax.request({
                        url: url,
                        method: 'POST',
                        headers: {'Content-Type': 'application/json; charset=UTF-8'},
                        jsonData: {
                            'from': record.json.hb_id,
                            'to': record.json.target_id,
                            'message': "!gostealth"
                        }
                    });
                  } else {
                    var url = "/api/webrtc/msg?token=" + beefwui.get_rest_token();
                    Ext.Ajax.request({
                        url: url,
                        method: 'POST',
                        headers: {'Content-Type': 'application/json; charset=UTF-8'},
                        jsonData: {
                            'from': record.json.target_id,
                            'to': record.json.hb_id,
                            'message': "!gostealth"
                        }
                    });
                  }
                }
              },{
                text: "Execute Command Module via RTC",
                handler: function() {
                  var url = "/api/webrtc/cmdexec?token=" + beefwui.get_rest_token();
                  var cmd_id = prompt("Enter command module ID:");
                  var cmd_opts = prompt("Parameters:");
                  if (cmd_opts == "") {
                    cmd_opts = "[]";
                  }
                  cmd_opts = JSON.parse(cmd_opts);
                  if (!cmd_id || cmd_id == "") {
                    return;
                  }
                  if (zombie_id === record.json.hb_id) {
                    Ext.Ajax.request({
                      url: url,
                      method: 'POST',
                      headers: {'Content-Type': 'application/json; charset=UTF-8'},
                      jsonData: {
                        'from': record.json.hb_id,
                        'to': record.json.target_id,
                        'cmdid': cmd_id,
                        'options': cmd_opts
                      }
                    });
                  } else {
                    Ext.Ajax.request({
                      url: url,
                      method: 'POST',
                      headers: {'Content-Type': 'application/json; charset=UTF-8'},
                      jsonData: {
                        'from': record.json.target_id,
                        'to': record.json.hb_id,
                        'cmdid': cmd_id,
                        'options': cmd_opts
                      }
                    });
                  }
                }
              }
            ]
          });
          grid.rowCtxMenu.showAt(e.getXY());
        } else if (record.json.status==="Stealthed!!") {
          grid.rowCtxMenu = new Ext.menu.Menu({
            items: [
              {
                text: "Command Peer to un-stealth",
                handler: function() {
                  if (zombie_id === record.json.hb_id) {
                    var url = "/api/webrtc/msg?token=" + beefwui.get_rest_token();
                    Ext.Ajax.request({
                        url: url,
                        method: 'POST',
                        headers: {'Content-Type': 'application/json; charset=UTF-8'},
                        jsonData: {
                            'from': record.json.hb_id,
                            'to': record.json.target_id,
                            'message': "!endstealth"
                        }
                    });
                  }
                }
              },{
                text: "Execute Command Module via RTC",
                handler: function() {
                  var url = "/api/webrtc/cmdexec?token=" + beefwui.get_rest_token();
                  var cmd_id = prompt("Enter command module ID:");
                  var cmd_opts = prompt("Parameters:");
                  if (cmd_opts == "") {
                    cmd_opts = "[]";
                  }
                  cmd_opts = JSON.parse(cmd_opts);
                  if (!cmd_id || cmd_id == "") {
                    return;
                  }
                  Ext.Ajax.request({
                    url: url,
                    method: 'POST',
                    headers: {'Content-Type': 'application/json; charset=UTF-8'},
                    jsonData: {
                      'from': record.json.hb_id,
                      'to': record.json.target_id,
                      'cmdid': cmd_id,
                      'options': cmd_opts
                    }
                  });
                }
              }
            ]
          });
          grid.rowCtxMenu.showAt(e.getXY());
        }
      },
      afterrender: function(datagrid) {
        datagrid.store.reload({params: {nonce: Ext.get("nonce").dom.value}});
      }
    }
		
	});
	
	var rtc_events_panel = new Ext.Panel({
		id: 'rtc-events-host-panel-zombie-'+zombie.session,
		title: 'Peers',
		items:[rtc_events_panel_grid],
		layout: 'fit',
		listeners: {
			activate: function(hosts_panel) {
				rtc_events_panel.items.items[0].store.reload({ params: {nonce: Ext.get ("nonce").dom.value} });
			}
		}
	});

	/*
	 * The panel that displays all command modules executed via RTC
	 ********************************************/
	var rtc_moduleevents_panel_store = new Ext.ux.data.PagingJsonStore({
		storeId: 'rtc-moduleevents-store-zombie-'+zombie.session,
		proxy: new Ext.data.HttpProxy({
			url: '/api/webrtc/cmdevents/'+zombie_id+'?token='+token,
			method: 'GET'
		}),
		remoteSort: false,
		autoDestroy: true,
		autoLoad: false,
		root: 'events',
		fields: ['id', 'hb_id', 'target_id', 'status', 'created_at', 'updated_at', 'mod'],
		sortInfo: {field: 'id', direction: 'ASC'}
	});

	var rtc_moduleevents_panel_bbar = new Ext.PagingToolbar({
		pageSize: req_pagesize,
		store: rtc_moduleevents_panel_store,
		displayInfo: true,
		displayMsg: 'Displaying RTC command events {0} - {1} of {2}',
		emptyMsg: 'No events to display'
	});

	var rtc_moduleevents_panel_grid = new Ext.grid.GridPanel({
		id: 'rtc-moduleevents-grid-zombie-'+zombie.session,
		store: rtc_moduleevents_panel_store,
		bbar: rtc_moduleevents_panel_bbar,
		border: false,
		loadMask: {msg:'Loading events...'},
		
		viewConfig: {
			forceFit: true
		},
		
		view: new Ext.grid.GridView({
			forceFit: true,
			emptyText: "No events",
			enableRowBody:true
		}),
		
		columns: [
			{header: 'Id', width: 5, sortable: true, dataIndex: 'id', hidden:true},
      {header: 'From', width: 10, sortable: true, dataIndex: 'hb_id', hidden:true},
      {header: 'Peer', width: 10, sortable: true, dataIndex: 'target_id', renderer: function(value){
              if (value === zombie_id) {
                return $jEncoder.encoder.encodeForHTML(value) + " (selected)";
              } else {
                return $jEncoder.encoder.encodeForHTML(value) + " (" + beefwui.get_info_from_id(value)['ip'] + ")";
              }
      }},
      {header: 'Module', width: 10, sortable: true, dataIndex: 'mod', renderer: function(value){
              return $jEncoder.encoder.encodeForHTML(value);
      }},
			{header: 'Status', width: 20, sortable: true, dataIndex: 'status', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Created At', width: 10, sortable: true, dataIndex: 'created_at', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Updated At', width: 10, sortable: true, dataIndex: 'updated_at', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}
		]
	});
	
	var rtc_moduleevents_panel = new Ext.Panel({
		id: 'rtc-moduleevents-host-panel-zombie-'+zombie.session,
		title: 'Command module results',
		items:[rtc_moduleevents_panel_grid],
		layout: 'fit',
		listeners: {
			activate: function(hosts_panel) {
				rtc_moduleevents_panel.items.items[0].store.reload({ params: {nonce: Ext.get ("nonce").dom.value} });
			}
		}
	});
        /*
         * The Network tab constructor
         ********************************************/
	ZombieTab_Rtc.superclass.constructor.call(this, {
		id: 'zombie-rtc-tab-zombie-'+zombie.session,
		title: 'WebRTC',
		activeTab: 0,
		viewConfig: {
			forceFit: true,
			stripRows: true,
			type: 'fit'
		},
    items: [rtc_events_panel,rtc_moduleevents_panel],
		bbar: commands_statusbar,
		listeners: {
		}
	});
	
};

Ext.extend(ZombieTab_Rtc, Ext.TabPanel, {});
