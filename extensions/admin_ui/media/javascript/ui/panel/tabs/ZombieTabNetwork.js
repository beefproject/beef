//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The Network tab panel for the selected zombie browser.
 * Loaded in /ui/panel/index.html
 */
ZombieTab_Network = function(zombie) {
	
	// The status bar.
	var commands_statusbar = new Beef_StatusBar('network-bbar-zombie-'+zombie.session);
	// RESTful API token
	var token = beefwui.get_rest_token();

	// get module ID from name
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
				commands_statusbar.update_fail("Error getting module id for '"+name+"'");
			}
		});
		return id;
	}

	/*
	 * arrayUnique()
	 */
	var arrayUnique = function(a) {
		return a.reduce(function(p, c) {
			if (p.indexOf(c) < 0) p.push(c);
			return p;
		}, []);
	};

	/*
	 * Draw the network map with vis.js
	 */
	var draw = function() {

		var hosts = null;
		var url = '/api/network/hosts/'+zombie.session+'?token='+token;
		$jwterm.ajax({
			contentType: 'application/json',
			dataType: 'json',
			type: 'GET',
			url: url,
			async: false,
			processData: false,
			loadMask: {msg:'Loading network hosts...'},
			success: function(data){
				hosts = data;
			},
			error: function(){
				commands_statusbar.update_fail('Error retrieving network hosts');
			}
		});
	
		var network = null;
		var DIR = '<%= @base_path %>/media/images/icons/';
		var EDGE_LENGTH_MAIN = 150;
		var EDGE_LENGTH_SUB = 50;

		var nodes = [];
		var edges = [];

		if (hosts.count == '0') {
			commands_statusbar.update_fail('Found no network hosts');
			return false;
		}

		nodes.push({id: 1000, label: '', image: DIR + '../beef.png', shape: 'image'});
		nodes.push({id: 1001, label: '', image: DIR + 'System-Firewall-2-icon.png', shape: 'image'});
		edges.push({from: 1000, to: 1001, length: EDGE_LENGTH_SUB});
		var HB_ID = 1002;
		nodes.push({id: HB_ID, label: 'Hooked Browser', image: DIR + 'Apps-internet-web-browser-icon.png', shape: 'image'});
		edges.push({from: 1001, to: HB_ID, length: EDGE_LENGTH_SUB});

		// add subnet nodes
		var subnets = [];
		for (var key in hosts.hosts) {
			if (isNaN(hosts.hosts[key].id)) continue;
			var ip = hosts.hosts[key].ip;
			var first = ip.split('.')[0];
			subnets.push(first);
		}
		subnets = arrayUnique(subnets);
		for (var i=0; i<=subnets.length; i++) {
			if (isNaN(subnets[i])) continue;
			nodes.push({id: subnets[i], label: subnets[i]+'.0.0.0/8', image: DIR + 'Network-Pipe-icon.png', shape: 'image'});
			edges.push({from: HB_ID, to: subnets[i], length: EDGE_LENGTH_SUB});
		}

		// add host nodes
		var i = 2000;
		for (var key in hosts.hosts) {
			if (isNaN(hosts.hosts[key].id)) continue;
			var ip = hosts.hosts[key].ip;
			var hostname = hosts.hosts[key].hostname;
			var type = hosts.hosts[key].type;
			var os = hosts.hosts[key].os;
			var label = ip;
			if (hostname) label += ' ['+hostname+']';
			if (os) label += "\n" + os;
			var icon = 'pc.png';
			nodes.push({id: i, label: label, image: DIR + icon, shape: 'image'});
			edges.push({from: ip.split('.')[0], to: i, length: EDGE_LENGTH_SUB});
			i++;
		}
	
		var container = document.getElementById('zombie_network');
		var data = {
			nodes: nodes,
			edges: edges
		};
		var options = {};
		network = new vis.Network(container, data, options);
	}
	
	/*
	 * Network Map panel
	 */
	var map_panel = new Ext.Panel({
		id: 'network-map-panel-zombie-'+zombie.session,
		title: 'Map',
		layout: 'fit',
		autoDestroy: true,
		html: '<div id="zombie_network"></div>',
		listeners: {
			activate: function(map_panel) {
				draw();
			}
		}
	});

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
		fields: ['id', 'ip', 'hostname', 'type', 'os', 'mac', 'lastseen'],
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
			{header: 'Type', width: 15, sortable: true, dataIndex: 'type', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'Operating System', width: 10, sortable: true, dataIndex: 'os', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
			{header: 'MAC Address', width: 10, sortable: true, dataIndex: 'mac', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
                        {header: 'Last Seen', width: 15, sortable: true, dataIndex: 'lastseen', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}
		],
		
		listeners: {
			rowclick: function(grid, rowIndex) {
				var r = grid.getStore().getAt(rowIndex).data;
			},
			contextmenu: function(e, element, options) {
				e.preventDefault();
			},
			containercontextmenu: function(view, e) {
				e.preventDefault();
				var emptygrid_menu = new Ext.menu.Menu({
					items: [
					{
						text: 'Get Internal IP Address',
						iconCls: 'network-host-ctxMenu-adapter',
						handler: function() {
							var mod_id = get_module_id("get_internal_ip_webrtc");
							commands_statusbar.update_sending('Identifying zombie network adapters ...');
							$jwterm.ajax({
								contentType: 'application/json',
								data: JSON.stringify({}),
								dataType: 'json',
								type: 'POST',
								url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
								async: false,
								processData: false,
								success: function(data){
									commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
								},
								error: function(){
									commands_statusbar.update_fail('Error sending command');
								}
							});
						}
					},{
                                                text: 'Discover Proxies',
                                                iconCls: 'network-host-ctxMenu-proxy',
                                                handler: function() {
                                                        var mod_id = get_module_id("get_proxy_servers_wpad");
                                                        commands_statusbar.update_sending('Scanning for WPAD proxies ...');
                                                        $jwterm.ajax({
                                                                contentType: 'application/json',
                                                                data: JSON.stringify({}),
                                                                dataType: 'json',
                                                                type: 'POST',
                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                async: false,
                                                                processData: false,
                                                                success: function(data){
                                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                },
                                                                error: function(){
                                                                        commands_statusbar.update_fail('Error sending command');
                                                                }
                                                        });
                                                }
					},{
						text: 'Discover Routers',
						iconCls: 'network-host-ctxMenu-router',
						handler: function() {
							var mod_id = get_module_id("fingerprint_routers");
							commands_statusbar.update_sending('Scanning commonly used local area network IP addresses for routers ...');
							$jwterm.ajax({
								contentType: 'application/json',
								data: JSON.stringify({}),
								dataType: 'json',
								type: 'POST',
								url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
								async: false,
								processData: false,
								success: function(data){
									commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
								},
								error: function(){
									commands_statusbar.update_fail('Error sending command');
								}
							});
						}
					},{
						text: 'Discover Web Servers',
						iconCls: 'network-host-ctxMenu-web',
						menu: {
						  xtype: 'menu',
						  items: [{
							text: 'Common LAN IPs',
							iconCls: 'network-host-ctxMenu-network',
							handler: function() {
								var mod_name = "get_http_servers";
								var mod_id = get_module_id(mod_name);
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
								commands_statusbar.update_sending('Favicon scanning commonly used local area network IP addresses for web servers [ports: '+ports+'] ...');
								$jwterm.ajax({
									contentType: 'application/json',
									data: JSON.stringify({"ipRange":"common","ports":ports}),
									dataType: 'json',
									type: 'POST',
									url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
									async: false,
									processData: false,
									success: function(data){
										commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
									},
									error: function(){
										commands_statusbar.update_fail('Error executing module ' + mod_name + ' [id: ' + mod_id + ']');
									}
								});
							}
						  },{
							text: 'Specify IP Range',
							iconCls: 'network-host-ctxMenu-config',
							handler: function() {
								var ip_range = prompt("Enter IP range to scan:", '192.168.1.1-192.168.1.254');
								if (!ip_range) {
									commands_statusbar.update_fail('Cancelled');
									return;
								}
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
								var mod_name = "get_http_servers";
								var mod_id = get_module_id(mod_name);
								commands_statusbar.update_sending('Favicon scanning ' + ip_range + ' for web servers...');
								$jwterm.ajax({
									contentType: 'application/json',
									data: JSON.stringify({"ipRange":ip_range,"ports":ports}),
									dataType: 'json',
									type: 'POST',
									url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
									async: false,
									processData: false,
									success: function(data){
										commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
									},
									error: function(){
										commands_statusbar.update_fail('Error executing module ' + mod_name + ' [id: ' + mod_id + ']');
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
                                                        text: 'Common LAN IPs',
                                                        iconCls: 'network-host-ctxMenu-network',
                                                        handler: function() {
                                                                var mod_name = "internal_network_fingerprinting";
                                                                var mod_id = get_module_id(mod_name);
                                                                commands_statusbar.update_sending('Fingerprinting commonly used local area network IP addresses...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipRange":"common"}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error executing module ' + mod_name + ' [id: ' + mod_id + ']');
                                                                        }
                                                                });
                                                        }
                                                  },{
                                                        text: 'Specify IP Range',
                                                        iconCls: 'network-host-ctxMenu-config',
                                                        handler: function() {
                                                                var ip_range = prompt("Enter IP range to scan:", '192.168.1.1-192.168.1.254');
                                                                if (!ip_range) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
                                                                var mod_name = "internal_network_fingerprinting";
                                                                var mod_id = get_module_id(mod_name);
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
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error executing module ' + mod_name + ' [id: ' + mod_id + ']');
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
                                                        text: 'Common LAN IPs',
                                                        iconCls: 'network-host-ctxMenu-network',
                                                        handler: function() {
                                                                var mod_name = "cross_origin_scanner_cors";
                                                                var mod_id = get_module_id(mod_name);
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
                                                                commands_statusbar.update_sending('CORS scanning commonly used local area network IP addresses [ports: '+ports+'] ...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipRange":"common","ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error executing module ' + mod_name + ' [id: ' + mod_id + ']');
                                                                        }
                                                                });
                                                        }
                                                  },{
                                                        text: 'Specify IP Range',
                                                        iconCls: 'network-host-ctxMenu-config',
                                                        handler: function() {
                                                                var ip_range = prompt("Enter IP range to scan:", '192.168.1.1-192.168.1.254');
                                                                if (!ip_range) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
                                                                var mod_name = "cross_origin_scanner_cors";
                                                                var mod_id = get_module_id(mod_name);
                                                                commands_statusbar.update_sending('CORS scanning ' + ip_range + ' [ports: ' + ports + '] ...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipRange":ip_range,"ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error executing module ' + mod_name + ' [id: ' + mod_id + ']');
                                                                        }
                                                                });
                                                        }
                                                  }]
                                                }
					}]
                                });
				emptygrid_menu.showAt(e.getXY());
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
                                // menu options for localhost
                                if (class_c == '127.0.0') {
                                  grid.rowCtxMenu = new Ext.menu.Menu({
                                        items: [
                                        {
                                          text: 'Discover Web Servers',
                                          iconCls: 'network-host-ctxMenu-web',
                                          handler: function() {
                                            var mod_id = get_module_id("get_http_servers");
                                            var ports = prompt("Enter ports to scan:", '80,8080');
                                            if (!ports) {
                                              commands_statusbar.update_fail('Cancelled');
                                                return;
                                              }
                                            commands_statusbar.update_sending('Favicon scanning ' + ip + ' for HTTP servers [ports: '+ports+'] ...');
                                            $jwterm.ajax({
                                              contentType: 'application/json',
                                              data: JSON.stringify({"ipRange":ip+'-'+ip,"ports":ports}),
                                              dataType: 'json',
                                              type: 'POST',
                                              url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                              async: false,
                                              processData: false,
                                              success: function(data){
                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                              },
                                              error: function(){
                                                commands_statusbar.update_fail('Error sending command');
                                              }
                                            });
                                          }
                                        },{
                                          text: 'Fingerprint HTTP',
                                          iconCls: 'network-host-ctxMenu-fingerprint',
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
                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
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
                                            var mod_id = get_module_id("cross_origin_scanner_cors");
                                            var ports = prompt("Enter ports to scan:", '80,8080');
                                            if (!ports) {
                                              commands_statusbar.update_fail('Cancelled');
                                              return;
                                            }
                                            commands_statusbar.update_sending('CORS scanning ' + ip + ' [ports: '+ports+'] ...');
                                            $jwterm.ajax({
                                              contentType: 'application/json',
                                              data: JSON.stringify({"ipRange":ip+'-'+ip,"ports":ports}),
                                              dataType: 'json',
                                              type: 'POST',
                                              url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                              async: false,
                                              processData: false,
                                              success: function(data){
                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                              },
                                              error: function(){
                                                commands_statusbar.update_fail('Error sending command');
                                              }
                                            });
                                          }
                                        },{
                                                text: 'Port Scan',
                                                iconCls: 'network-host-ctxMenu-network',
                                                menu: {
                                                  xtype: 'menu',
                                                  items: [{
                                                        text: 'Common Ports',
                                                        iconCls: 'network-host-ctxMenu-host',
                                                        handler: function() {
                                                                var mod_id = get_module_id("port_scanner");
                                                                var ports = '21,22,23,25,80,81,443,445,1080,8080,8081,8090,8443,3000,3128,3389,3306,5432,6379,10000,10443';
                                                                commands_statusbar.update_sending('Port scanning ' + ip + '...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipHost":ip,"ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error sending command');
                                                                        }
                                                                });
                                                        }
                                                  },{
                                                        text: 'Specify Ports',
                                                        iconCls: 'network-host-ctxMenu-config',
                                                        handler: function() {
                                                                var mod_id = get_module_id("port_scanner");
                                                                var ports = prompt("Enter ports to scan:", '1,5,7,9,15,20,21,22,23,25,26,29,33,37,42,43,53,67,68,69,70,76,79,80,88,90,98,101,106,109,110,111,113,114,115,118,119,123,129,132,133,135,136,137,138,139,143,144,156,158,161,162,168,174,177,194,197,209,213,217,219,220,223,264,315,316,346,353,389,413,414,415,416,440,443,444,445,453,454,456,457,458,462,464,465,466,480,486,497,500,501,516,518,522,523,524,525,526,533,535,538,540,541,542,543,544,545,546,547,556,557,560,561,563,564,625,626,631,636,637,660,664,666,683,740,741,742,744,747,748,749,750,751,752,753,754,758,760,761,762,763,764,765,767,771,773,774,775,776,780,781,782,783,786,787,799,800,801,808,871,873,888,898,901,953,989,990,992,993,994,995,996,997,998,999,1000,1002,1008,1023,1024,1080,8080,8443,8050,3306,5432,1521,1433,3389,10088');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
                                                                commands_statusbar.update_sending('Port scanning ' + ip + '...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipHost":ip,"ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
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
				// menu options for all hosts other than 127.0.0.x
				} else {
				  grid.rowCtxMenu = new Ext.menu.Menu({
					items: [
					{
                                                text: 'Discover Web Servers',
						iconCls: 'network-host-ctxMenu-web',
                                                menu: {
                                                  xtype: 'menu',
                                                  items: [{
                                                        text: 'Host ('+ip+')',
                                                        iconCls: 'network-host-ctxMenu-host',
                                                        handler: function() {
                                                                var mod_id = get_module_id("get_http_servers");
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
                                                                commands_statusbar.update_sending('Favicon scanning ' + ip + ' for HTTP servers [ports: '+ports+'] ...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipRange":ip+'-'+ip,"ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
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
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
                                                                var mod_id = get_module_id("get_http_servers");
                                                                commands_statusbar.update_sending('Favicon scanning ' + ip_range + ' for HTTP servers [ports: '+ports+'] ...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipRange":ip_range,"ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
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
	                                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
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
	                                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
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
								var mod_id = get_module_id("cross_origin_scanner_cors");
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
	                                                        commands_statusbar.update_sending('CORS scanning ' + ip + ' [ports: '+ports+'] ...');
	                                                        $jwterm.ajax({
	                                                                contentType: 'application/json',
	                                                                data: JSON.stringify({"ipRange":ip+'-'+ip,"ports":ports}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
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
	                                                        var mod_id = get_module_id("cross_origin_scanner_cors");
                                                                var ports = prompt("Enter ports to scan:", '80,8080');
                                                                if (!ports) {
                                                                        commands_statusbar.update_fail('Cancelled');
                                                                        return;
                                                                }
	                                                        commands_statusbar.update_sending('CORS scanning ' + ip_range + ' [ports: '+ports+'] ...');
	                                                        $jwterm.ajax({
	                                                                contentType: 'application/json',
	                                                                data: JSON.stringify({"ipRange":ip_range,"ports":ports}),
	                                                                dataType: 'json',
	                                                                type: 'POST',
	                                                                url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
	                                                                async: false,
	                                                                processData: false,
	                                                                success: function(data){
	                                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
	                                                                },
	                                                                error: function(){
	                                                                        commands_statusbar.update_fail('Error sending command');
	                                                                }
	                                                        });
                                                        }
                                                  }]
						}
                                        },{
                                                text: 'Port Scan',
                                                iconCls: 'network-host-ctxMenu-network',
                                                menu: {
                                                  xtype: 'menu',
                                                  items: [{
                                                        text: 'Common Ports',
                                                        iconCls: 'network-host-ctxMenu-host',
                                                        handler: function() {
                                                                var mod_id = get_module_id("port_scanner");
                                                                var ports = '21,22,23,25,80,81,443,445,1080,8080,8081,8090,8443,3000,3128,3389,3306,5432,6379,10000,10443';
                                                                commands_statusbar.update_sending('Port scanning ' + ip + '...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipHost":ip,"ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error sending command');
                                                                        }
                                                                });
                                                        }
                                                  },{
                                                        text: 'Specify Ports',
                                                        iconCls: 'network-host-ctxMenu-config',
                                                        handler: function() {
                                                                var mod_id = get_module_id("port_scanner");
								var ports = prompt("Enter ports to scan:", '1,5,7,9,15,20,21,22,23,25,26,29,33,37,42,43,53,67,68,69,70,76,79,80,88,90,98,101,106,109,110,111,113,114,115,118,119,123,129,132,133,135,136,137,138,139,143,144,156,158,161,162,168,174,177,194,197,209,213,217,219,220,223,264,315,316,346,353,389,413,414,415,416,440,443,444,445,453,454,456,457,458,462,464,465,466,480,486,497,500,501,516,518,522,523,524,525,526,533,535,538,540,541,542,543,544,545,546,547,556,557,560,561,563,564,625,626,631,636,637,660,664,666,683,740,741,742,744,747,748,749,750,751,752,753,754,758,760,761,762,763,764,765,767,771,773,774,775,776,780,781,782,783,786,787,799,800,801,808,871,873,888,898,901,953,989,990,992,993,994,995,996,997,998,999,1000,1002,1008,1023,1024,1080,8080,8443,8050,3306,5432,1521,1433,3389,10088');
								if (!ports) {
									commands_statusbar.update_fail('Cancelled');
									return;
								}       
                                                                commands_statusbar.update_sending('Port scanning ' + ip + '...');
                                                                $jwterm.ajax({
                                                                        contentType: 'application/json',
                                                                        data: JSON.stringify({"ipHost":ip,"ports":ports}),
                                                                        dataType: 'json',
                                                                        type: 'POST',
                                                                        url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                                        async: false,
                                                                        processData: false,
                                                                        success: function(data){
                                                                                commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                                        },
                                                                        error: function(){
                                                                                commands_statusbar.update_fail('Error sending command');
                                                                        }
                                                                });
                                                        }
                                                  }]
                                                }
					},{
						xtype: 'menuseparator'
					},{
						text: 'Remove',
						iconCls: 'zombie-tree-ctxMenu-delete',
						handler: function() {
							var host_id = record.get('id');
							if (!confirm('Are you sure you want to remove network host [id: '+host_id+', ip: '+ ip +'] ?')) {
								commands_statusbar.update_fail('Cancelled');
								return;
							}

							commands_statusbar.update_sending('Removing network host [id: '+ host_id +', ip: '+ ip +'] ...');
							$jwterm.ajax({
								contentType: 'application/json',
								dataType: 'json',
								type: 'DELETE',
								url: "/api/network/host/" + host_id + "?token=" + token,
								async: false,
								processData: false,
								success: function(data){
									try {
										if (data.success) {
											commands_statusbar.update_sent('Removed network host successfully');
											Ext.getCmp('network-host-grid-zombie-'+zombie.session).getStore().reload();
										} else {
											commands_statusbar.update_fail('Could not remove network host');
										}
									} catch(e) {
										commands_statusbar.update_fail('Could not remove network host');
									}
								},
								error: function(){
									commands_statusbar.update_fail('Could not remove host');
								}
							});
						}
					}]
				  });
                                }
				grid.rowCtxMenu.showAt(e.getXY());
			},
			afterrender: function(datagrid) {
				datagrid.store.reload({ params: {nonce: Ext.get ("nonce").dom.value} });
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
				hosts_panel.items.items[0].store.reload({ params: {nonce: Ext.get ("nonce").dom.value} });
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
                                            text: 'Fingerprint HTTP',
                                            iconCls: 'network-host-ctxMenu-fingerprint',
                                            handler: function () {
                                                var mod_id = get_module_id("internal_network_fingerprinting");
                                                commands_statusbar.update_sending('Fingerprinting ' + ip + '...');
                                                $jwterm.ajax({
                                                    contentType: 'application/json',
                                                    data: JSON.stringify({"ipRange": ip + '-' + ip, "ports": port}),
                                                    dataType: 'json',
                                                    type: 'POST',
                                                    url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                    async: false,
                                                    processData: false,
                                                    success: function (data) {
                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                    },
                                                    error: function () {
                                                        commands_statusbar.update_fail('Error sending command');
                                                    }
                                                });
                                            }
                                        }, {
                                            text: 'CORS Scan',
                                            iconCls: 'network-host-ctxMenu-cors',
                                            handler: function () {
                                                var mod_id = get_module_id("cross_origin_scanner_cors");
                                                commands_statusbar.update_sending('CORS scanning ' + ip + ' [port: '+port+'] ...');
                                                $jwterm.ajax({
                                                    contentType: 'application/json',
                                                    data: JSON.stringify({"ipRange": ip + '-' + ip, "ports": port}),
                                                    dataType: 'json',
                                                    type: 'POST',
                                                    url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                    async: false,
                                                    processData: false,
                                                    success: function (data) {
                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                    },
                                                    error: function () {
                                                        commands_statusbar.update_fail('Error sending command');
                                                    }
                                                });
                                            }
                                        }, {
                                            text: 'Shellshock Scan',
                                            iconCls: 'network-host-ctxMenu-shellshock',
                                            handler: function () {
                                                var mod_id = get_module_id("shell_shock_scanner");
                                                var lhost = prompt("Enter local IP for connect back shell:", 'LHOST');
                                                if (!lhost || lhost == 'LHOST') {
                                                    commands_statusbar.update_fail('Cancelled');
                                                    return;
                                                }
                                                var lport = prompt("Enter local port for connect back shell:", 'LPORT');
                                                if (!lport || lport == 'LPORT') {
                                                    commands_statusbar.update_fail('Cancelled');
                                                    return;
                                                }
                                                alert("Now start your reverse shell handler on " + lhost + ':' + lport);
                                                commands_statusbar.update_sending('Shellshock scanning ' + ip + '...');
                                                $jwterm.ajax({
                                                    contentType: 'application/json',
                                                    data: JSON.stringify({
                                                        "rproto": proto,
                                                        "rhost": ip,
                                                        "rport": port,
                                                        "lhost": lhost,
                                                        "lport": lport
                                                    }),
                                                    dataType: 'json',
                                                    type: 'POST',
                                                    url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                    async: false,
                                                    processData: false,
                                                    success: function (data) {
                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                    },
                                                    error: function () {
                                                        commands_statusbar.update_fail('Error sending command');
                                                    }
                                                });
                                            }
                                        }, {
                                            text: 'RFI Scan',
                                            iconCls: 'network-host-ctxMenu-php',
                                            handler: function () {
                                                var mod_id = get_module_id("rfi_scanner");
                                                var lhost = prompt("Enter local IP for connect back shell:", 'LHOST');
                                                if (!lhost || lhost == 'LHOST') {
                                                    commands_statusbar.update_fail('Cancelled');
                                                    return;
                                                }
                                                var lport = prompt("Enter local port for connect back shell:", 'LPORT');
                                                if (!lport || lport == 'LPORT') {
                                                    commands_statusbar.update_fail('Cancelled');
                                                    return;
                                                }
                                                alert("Now start your reverse shell handler on " + lhost + ':' + lport);
                                                commands_statusbar.update_sending('Shellshock scanning ' + ip + '...');
                                                $jwterm.ajax({
                                                    contentType: 'application/json',
                                                    data: JSON.stringify({
                                                        "rproto": proto,
                                                        "rhost": ip,
                                                        "rport": port,
                                                        "lhost": lhost,
                                                        "lport": lport,
                                                        "payload": "reverse_php"
                                                    }),
                                                    dataType: 'json',
                                                    type: 'POST',
                                                    url: "/api/modules/" + zombie.session + "/" + mod_id + "?token=" + token,
                                                    async: false,
                                                    processData: false,
                                                    success: function (data) {
                                                        commands_statusbar.update_sent("Command [id: " + data.command_id + "] sent successfully");
                                                    },
                                                    error: function () {
                                                        commands_statusbar.update_fail('Error sending command');
                                                    }
                                                });
                                            }
                                }]
                            });
                            grid.rowCtxMenu.showAt(e.getXY());
                        },
                    afterrender: function (datagrid) {
                        datagrid.store.reload({params: {nonce: Ext.get("nonce").dom.value}});
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
				services_panel.items.items[0].store.reload({ params: {nonce: Ext.get ("nonce").dom.value} });
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
        	items: [map_panel, hosts_panel, services_panel],
		bbar: commands_statusbar,
		listeners: {
		}
	});
	
};

Ext.extend(ZombieTab_Network, Ext.TabPanel, {});
