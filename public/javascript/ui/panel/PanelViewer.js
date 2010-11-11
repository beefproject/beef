PanelViewer = {};
var mainPanel, zombiesPanel;

Ext.onReady(function() {
	
	Ext.QuickTips.init();

	zombiesPanel = new ZombiesPanel();
	mainPanel = new MainPanel();
	
	var viewport = new Ext.Viewport({
        layout:'border',
        items:[
            new Ext.BoxComponent({
                region:'north',
                el: 'header',
                height: 32
            }),
			zombiesPanel,
			mainPanel
         ]
    });
	
	new DoLogout();
	new AboutWindow();
	new ZombiesMgr(zombiesPanel);
});