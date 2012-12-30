//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

ZombieTabs = function(zombie_tree_list) {
	
	//a variable to store the list of trees.
	this.tree_items = new Array;
	
	//we store the list of trees in a correct array format for ExtJs
	for(tree_name in zombie_tree_list) {
		var tree = zombie_tree_list[tree_name];
		
		//set the tree as distributed if it's not the basic tree
		if(tree_name != "basic") {
			tree.tree_configuration["distributed"] = true;
		}
		
		this.tree_items.push(tree);
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

/* the "sort by" functionality is not used yet

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
*/
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
		items: this.tree_items
//		bbar: this.bottom_bar
    });
};

Ext.extend(ZombieTabs, Ext.TabPanel);
