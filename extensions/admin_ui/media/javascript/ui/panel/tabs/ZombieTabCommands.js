//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The command tab panel. Listing the list of commands sent to the zombie.
 * Loaded in /ui/panel/index.html 
 */
ZombieTab_Commands = function(zombie) {
	var originalRoot;
	
	var command_module_config = new Ext.Panel({
		id: 'zombie-command-module-config-'+zombie.session,
		region: 'center',
		border: true,
		layout: 'fit'
	});

	var command_module_grid = new Ext.grid.GridPanel({
		store: new Ext.data.JsonStore({
				url: '<%= @base_path %>/modules/commandmodule/commands.json',
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
					return 'command '+($jEncoder.encoder.encodeForHTML(record.get("id")+1));
				}
			},
			{header: 'object_id', sortable: true, dataIndex: 'object_id', hidden: true, menuDisabled: true}
		]
	});
	
	command_module_grid.on('rowclick', function(grid, rowIndex, e) {
		var r = grid.getStore().getAt(rowIndex).data;
		var command_id = r.object_id || null;
		
		if(!command_id) return;
		
		genExistingExploitPanel(command_module_config, command_id, zombie, commands_statusbar);
	});
	
	LoadCommandPanelEvent = function(node,keyclick) {
		if(!node.leaf && !keyclick) {
			node.toggle();
		} else if (!node.leaf && keyclick) {
			return;
		} else {
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
	
	var command_module_tree_search = new Ext.form.TextField( {
		emptyText: 'Search',
		id: 'module-search-' + zombie.session,
		style: {
			width: '100%'
			},
		listeners: {
			specialkey : function(field,e){
				if(e.getKey() == e.ENTER){
					if( field.getValue() ){
						var root = {
										text: "Search results",
										children: search_module(originalRoot, field.getValue())
						};
						command_module_tree.setRootNode(root);
					} else 
						command_module_tree.setRootNode(originalRoot);
						
				}
			}
		}
	});
	
	var command_module_tree_search_panel = new Ext.Panel({
        id: "zombie-command-modules-search-panel"+zombie.session,
		items: [ command_module_tree_search ],
        width: 190,
        minSize: 190,
        maxSize: 500,
        region: 'north'
	});

	var command_module_tree = new Ext.tree.TreePanel({
		id: "zombie-command-modules"+zombie.session,
		region: 'center',
		width: 190,
        minSize: 190,
        maxSize: 500,
		useArrows: true,
		autoScroll: true,
		animate: true,
		containerScroll: true,
		rootVisible: false,
		root: {nodeType: 'async'},
		loader: new Ext.tree.TreeLoader({
          dataUrl: '<%= @base_path %>/modules/select/commandmodules/tree.json',
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
						originalRoot = command_module_tree.root.childNodes;
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
			},
			'activate' : function() {
			},
			'deactivate' : function() {
			},
			'select' : function() {
			},
			'keyup' : function() {
			},
			'render' : function(c) {
				c.getEl().on('keyup', function(a) {
                    LoadCommandPanelEvent(Ext.getCmp('zombie-command-modules'+zombie.session).getSelectionModel().getSelectedNode(),true);
                });
            }
		}
	});

	var command_module_tree_container = new Ext.Panel({
        id: "zombie-command-modules-container"+zombie.session,
		title: "Module Tree",
		border: true,
        width: 190,
        minSize: 190,
        maxSize: 500, // if some command module names are even longer, adjust this value
        layout: 'border',
        region: 'west',
        split: true,
		items: [ command_module_tree_search_panel,command_module_tree ],
	});


	var commands_statusbar = new Beef_StatusBar(zombie.session);
	
	ZombieTab_Commands.superclass.constructor.call(this, {
		id: 'zombie-'+zombie.session+'-command-module-panel',
		title:'Commands',
		layout: 'fit',
		region: 'center',
		items: {
			layout: 'border',
			border: false,
            // enable width resize of the command_module_tree
            defaults: {
                collapsible: false,
                split: true
            },
			items: [
                    command_module_tree_container,
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

Ext.extend(ZombieTab_Commands, Ext.Panel, {
    listeners: {
    		close: function(panel) {}
    	}
});
