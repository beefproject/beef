//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
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
/*
 * The command tab panel. Listing the list of commands sent to the zombie.
 * Loaded in /ui/panel/index.html 
 */
ZombieTab_Commands = function(zombie) {
	
	var command_module_config = new Ext.Panel({
		id: 'zombie-command-module-config-'+zombie.session,
		region: 'center',
		border: true,
		layout: 'fit',
        autoScroll: true
    });

    var welcomeWindow = new Ext.Window({
				title: 'Welcome to the BeEF Command Modules',
				id: 'welcome-window',
				closable:true,
				width:450,
				height:300,
				plain:true,
				layout: 'border',
				shadow: true,
				items: [
                    new Ext.Panel({
                    region: 'center',
                    padding: '3 3 3 3',
                    html: "At your left you have all the BeEF command modules organized in a category tree.<br/><br/> " +
                          "Most command modules consist of Javascript code that is executed against the selected " +
                          "Hooked Browser. Command modules are able to perform any actions that can be achieved " +
                          "through Javascript: for example they may gather information about the Hooked Browser, manipulate the DOM " +
                          "or perform other activities such as exploiting vulnerabilities within the local network " +
                          "of the Hooked Browser.<br/><br/>To learn more about writing your own modules please review " +
                          "the wiki:<br /><a href='https://code.google.com/p/beef/wiki/CommandModuleAPI'>" +
                            "https://code.google.com/p/beef/wiki/CommandModuleAPI</a><br/><br/>" +
                            "Each command module has a traffic light icon, which is used to indicate the following:<ul>" +
                            "<li><img alt='' src='media/images/icons/green.png'  unselectable='on'> - The command works against the target and should be invisible to the user</li>" +
                            "<li><img alt='' src='media/images/icons/orange.png'  unselectable='on'> - The command works against the target, but may be visible to the user</li>" +
                            "<li><img alt='' src='media/images/icons/grey.png'  unselectable='on'> - It is unknown if this command works against this target</li>" +
                            "<li><img alt='' src='media/images/icons/red.png'  unselectable='on'> - Command does not work against this target</li></ul>"

                })
               ]
    });
	
	var command_module_grid = new Ext.grid.GridPanel({
		store: new Ext.data.JsonStore({
				url: '/ui/modules/commandmodule/commands.json',
				params: {  // insert the nonce with the form
						nonce: Ext.get ("nonce").dom.value
				},
				autoDestroy: false,
				autoLoad: false,
				root: 'commands',
				fields: ['label', 'creationdate', 'id', 'object_id'],
				sortInfo: {field: 'id', direction: 'ASC'}
			}),
		
		id: 'command-module-grid-zombie-'+zombie.session,
		title: "Module Results History",
		sortable: true,
		autoWidth: false,
		region: 'west',
		stripeRows: true,
		autoScroll: true,
		border: true,
		width: 260,
		i:0,
		minSize: 160,
		maxSize: 300,
		split: true,

		view: new Ext.grid.GridView({
			forceFit: true,
			emptyText: "The results from executed command modules will be listed here.",
			enableRowBody:true
		}),
		
		columns: [
			{header: 'id', width: 35, sortable: true, dataIndex: 'id'},
			{header: 'date', width: 100, sortable: true, dataIndex: 'creationdate'},
			{header: 'label', sortable: true, dataIndex: 'label', renderer: 
				function(value, metaData, record, rowIndex, colIndex, store) {
					return 'command '+(record.get("id")+1);
				}
			},
			{header: 'object_id', sortable: true, dataIndex: 'object_id', hidden: true, menuDisabled: true}
		]
	});
	
	command_module_grid.on('rowclick', function(grid, rowIndex, e) {
		var r = grid.getStore().getAt(rowIndex).data;
		var command_id = r.object_id || null;
		
		if(!command_id) return;
		
		genExisingExploitPanel(command_module_config, command_id, zombie, commands_statusbar);
	});
	
	LoadCommandPanelEvent = function(node,keyclick) {
		if(!node.leaf && !keyclick) {
			node.toggle();
		} else if (!node.leaf && keyclick) {
			return;
		} else {
            // if the user don't close the welcome window, let hide it automatically
            welcomeWindow.hide();

			command_module_config.configLoadMask = new Ext.LoadMask(Ext.getBody(), {msg:"Please wait, module config is loading..."});
			command_module_config.configLoadMask.show();

            command_module_grid.i = 0;
			command_module_grid.store.baseParams = {command_module_id: node.attributes.id, zombie_session: zombie.session};
			command_module_grid.store.reload({  //reload the command module grid
				params: {  // insert the nonce with the request to reload the grid
					nonce: Ext.get ("nonce").dom.value
			}		
			});
			
			genNewExploitPanel(command_module_config, node.id, node.text, zombie, commands_statusbar);
			commands_statusbar.showValid('Ready');
		}
	};
	
	var command_module_tree = new Ext.tree.TreePanel({
		id: "zombie-command-modules"+zombie.session,
		title: "Module Tree",
		border: true,
		region: 'west',
		width: 190,
        minSize: 190,
        maxSize: 500, // if some command module names are even longer, adjust this value
		useArrows: true,
		autoScroll: true,
		animate: true,
		containerScroll: true,
		rootVisible: false,
		root: {nodeType: 'async'},
		loader: new Ext.tree.TreeLoader({
          dataUrl: '/ui/modules/select/commandmodules/tree.json',
          baseParams: {zombie_session: zombie.session},
          listeners:{
            beforeload: function(treeloader, node, callback) {
                       // Show loading mask on body, to prevent the user interacting with the UI
                       treeloader.treeLoadingMask = new Ext.LoadMask(Ext.getBody(), {msg:"Please wait, command tree is loading..."});
                       treeloader.treeLoadingMask.show();
                       return true;
             },
             load: function(treeloader, node, response) {
                       // Hide loading mask after tree is fully loaded
                       treeloader.treeLoadingMask.hide();
                       if(Ext.get('welcomeWinShown') == null){
                         welcomeWindow.show();
                         // add a div in the header section, to prevent displaying the Welcome Window every time
                         // the module_tree_panel is loaded
                         Ext.DomHelper.append('header', {tag: 'div', id: 'welcomeWinShown'});
                       }
                       return true;
             }
          }
        }),
		listeners: {
			'click': function(node) {
				LoadCommandPanelEvent(node,false);
			},
			'afterrender' : function() {
			},
			'selectionchange' : function() {
				console.log("selection changed");
			},
			'activate' : function() {
				console.log("activate");
			},
			'select' : function() {
				console.log("select");
			},
			'keyup' : function() {
				console.log("Key up");
			},
			'render' : function(c) {
				c.getEl().on('keyup', function() {
					LoadCommandPanelEvent(Ext.getCmp('zombie-command-modules'+zombie.session).getSelectionModel().getSelectedNode(),true);
				});
			}
		}
	});

	var commands_statusbar = new Beef_StatusBar(zombie.session);
	
	ZombieTab_Commands.superclass.constructor.call(this, {
		id: 'zombie-'+zombie.session+'-command-module-panel',
		title:'Commands',
		layout: 'fit',
		region: 'center',
		autoScroll: true,
		items: {
			layout: 'border',
			border: false,
            // enable width resize of the command_module_tree
            defaults: {
                collapsible: false,
                split: true
            },
			items: [command_module_tree, 
				new Ext.Panel({
					id: 'zombie-command-module-west-'+zombie.session,
					region: 'center',
					layout: 'border',
					border: false,
					items: [command_module_grid, command_module_config]
			})]
		},

		bbar: commands_statusbar
	});
	
	var sb = Ext.getCmp('command-module-bbar-zombie-'+zombie.session);
};

Ext.extend(ZombieTab_Commands, Ext.Panel, {});
