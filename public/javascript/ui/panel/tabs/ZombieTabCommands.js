/*
 * The command tab panel. Listing the list of commands sent to the zombie.
 * Loaded in /ui/panel/index.html 
 */
ZombieTab_Commands = function(zombie) {
	
	var command_module_config = new Ext.Panel({
		id: 'zombie-command-module-config-'+zombie.session,
		region: 'center',
		border: false,
		layout: 'fit',
		html: "<div class='x-grid-empty'>Please select an command module in the command module tree on the left</div>"
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
		sortable: true,
		autoWidth: false,
		region: 'west',
		stripeRows: true,
		autoScroll: true,
		border: false,
		width: 260,
		bodyStyle: 'border-right: 1px solid #99BBE8; border-left: 1px solid #99BBE8;',
		i:0,
		
		view: new Ext.grid.GridView({
			forceFit: true,
			emptyText: "The results from executed command modules will be listed here.",
			enableRowBody:true
		}),
		
		columns: [
			{header: 'id', width: 35, sortable: true, dataIndex: 'id'},
			{header: 'date', width: 100, sortable: true, dataIndex: 'creationdate'},
			{header: 'label', sortable: true, dataIndex: 'label', renderer: function(value) { if(value==null) {command_module_grid.i +=1; return 'command '+command_module_grid.i;} else return value;}},
			{header: 'object_id', sortable: true, dataIndex: 'object_id', hidden: true, menuDisabled: true}
		]
	});
	
	command_module_grid.on('rowclick', function(grid, rowIndex, e) {
		var r = grid.getStore().getAt(rowIndex).data;
		var command_id = r.object_id || null;
		
		if(!command_id) return;
		
		genExisingExploitPanel(command_module_config, command_id, zombie, commands_statusbar);
	});
	
	var command_module_tree = new Ext.tree.TreePanel({
		border: false,
		region: 'west',
		width: 190,
		useArrows: true,
		autoScroll: true,
		animate: true,
		containerScroll: true,
		rootVisible: false,
		root: {nodeType: 'async'},
		loader: new Ext.tree.TreeLoader({
          dataUrl: '/ui/modules/select/commandmodules/tree.json',
          baseParams: {zombie_session: zombie.session} 
        }),
		listeners: {
			'click': function(node) {
				if(!node.leaf) {
					node.toggle();
				} else {
					commands_statusbar.showBusy('Loading ' + node.text);
					
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
			},
			'afterrender' : function() {
			}
		}
	});

	var commands_statusbar = new Beef_StatusBar(zombie.session);
	
	ZombieTab_Commands.superclass.constructor.call(this, {
		id: 'zombie-'+zombie.session+'-command-module-panel',
		title:'Commands',
		layout: 'fit',
		region: 'center',
		autScroll: true,
		items: {
			layout: 'border',
			border: false,
			items: [command_module_tree, 
				new Ext.Panel({
					id: 'zombie-command-module-west-'+zombie.session,
					region: 'center',
					layout: 'fit',
					border: false,
					items: {
						layout: 'border',
						border: false,
						items: [command_module_grid, command_module_config]
					}
			})]
		},

		bbar: commands_statusbar
	});
	
	var sb = Ext.getCmp('command-module-bbar-zombie-'+zombie.session);
};

Ext.extend(ZombieTab_Commands, Ext.Panel, {});
