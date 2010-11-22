ZombieTabs = function(zombie_tree_list) {
	
	var tree_items = new Array;
	
	for(tree in zombie_tree_list) {
		tree_items.push(zombie_tree_list[tree]);
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
		items: tree_items
    });
};

Ext.extend(ZombieTabs, Ext.TabPanel);