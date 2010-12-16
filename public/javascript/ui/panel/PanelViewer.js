PanelViewer = {};
var mainPanel, zombiesTreeLists, zombieTabs;

Ext.onReady(function() {
	
	Ext.QuickTips.init();

	zombiesTreeLists = {
		'basic' : new zombiesTreeList('basic'),
		'requester' : new zombiesTreeList('requester')
	};
	
	zombieTabs = new ZombieTabs(zombiesTreeLists);
	mainPanel = new MainPanel();
	
	var viewport = new Ext.Viewport({
        layout:'border',
        items:[
            new Ext.BoxComponent({
                region:'north',
                el: 'header',
                height: 32
            }),
			zombieTabs,
			mainPanel
         ]
    });
	
	new DoLogout();
	new AboutWindow();
	new ZombiesMgr(zombiesTreeLists);
});