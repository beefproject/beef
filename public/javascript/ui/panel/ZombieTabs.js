ZombieTabs = function(zombie_tree_list) {
	
	//a variable to store the list of trees.
	this.tree_items = new Array;
	
	//we store the list of trees in a correct array format for ExtJs
	for(tree in zombie_tree_list) {
		this.tree_items.push(zombie_tree_list[tree]);
	}
	
	/*
	 * Update each tree with a new configuration and regenerates them.
	 * @param: {Literal Object} updated configuration for the trees
	 */
	function update_trees_configuration(configuration) {
		var tree_panel = Ext.getCmp("zombie-tree-tabs-panel");
		var trees = tree_panel.items;
		
		Ext.each(trees.items, function(tree) {
			tree.updateConfiguration(configuration);
			tree.reload();
		});
	};
	
	//the bottom bar for that panel
	this.bottom_bar = new Ext.Toolbar({
		items: [
			{
				xtype: 'tbtext',
				text: 'Sort by:'
			},
			{
				//list the hooked browsers by domain
				text: 'domain',
				listeners: {
					click: function(b) {
						update_trees_configuration({'sub-branch' : 'domain'});
					}
				}
			},
			'-',
			{
				//list the hooked browsers by external ip
				text: 'external ip',
				listeners: {
					click: function() {
						alert('under construction');
					}
				}
			}
		]
	});
	
	MainPanel.superclass.constructor.call(this, {
        id: 'zombie-tree-tabs-panel',
		title: 'Hooked Browsers',
		headerAsText: true,
		tabPosition: 'bottom',
		region:'west',
		activeTab: 0,
		margins:'0 5 5 5',
       	width: 225,
        minSize: 175,
        maxSize: 400,
		deferredRender: false,
		items: this.tree_items,
		bbar: this.bottom_bar
    });
};

Ext.extend(ZombieTabs, Ext.TabPanel);