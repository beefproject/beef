MainPanel = function(){
    this.preview = new Ext.Panel({
        id: 'preview',
        region: 'south',
        cls:'preview',
        autoScroll: true,
        listeners: PanelViewer.LinkInterceptor,

        tbar: [{
            id:'tab',
            text: 'View in New Tab',
            iconCls: 'new-tab',
            disabled:true,
            handler : this.openTab,
            scope: this
        }],

        clear: function(){
            this.body.update('');
            var items = this.topToolbar.items;
            items.get('tab').disable();
            items.get('win').disable();
        }
    });

    this.grid = new DataGrid('/ui/logs/all.json',25);
	this.grid.border = false;
    this.welcome_tab = new WelcomeTab;

    MainPanel.superclass.constructor.call(this, {
        id:'main-tabs',
        activeTab:0,
        region:'center',
        margins:'0 5 5 0',
        resizeTabs:true,
        tabWidth:150,
        minTabWidth: 120,
        enableTabScroll: true,
        plugins: new Ext.ux.TabCloseMenu(),
        items: [{
            id:'welcome-view',
            title:'Getting Started',
            layout:'border',
            hideMode:'offsets',
            closable:true,
            plain:true,
            shadow:true,
            items:[
                this.welcome_tab
            ]},{
            id:'logs-view',
            layout:'border',
            title:'Logs',
            hideMode:'offsets',
            items:[
                this.grid
            ]
        }]
    });
	
};

Ext.extend(MainPanel, Ext.TabPanel);


Ext.reg('appmainpanel', MainPanel);
