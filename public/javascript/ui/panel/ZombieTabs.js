ZombieTabs = function(zombie_tree_list) {
	
	//a variable to store the list of trees.
	this.tree_items = new Array;
	
	//we store the list of trees in a correct array format for ExtJs
	for(tree in zombie_tree_list) {
		this.tree_items.push(zombie_tree_list[tree]);
	}
	
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
    });
};

Ext.extend(ZombieTabs, Ext.TabPanel);