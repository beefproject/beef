//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
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

    this.grid = new DataGrid('/ui/logs/all.json',30);
	this.grid.border = false;
    this.welcome_tab = new WelcomeTab;
    //this.hackvertor_tab = new HackVertorTab;

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
            /*
            ]},{
            id:'hackvertor-view',
            layout:'border',
            title:'HackVertor',
            hideMode:'offsets',
            items:[
                //this.hackvertor_tab
            */
            ]
        }]
    });
	
};

Ext.extend(MainPanel, Ext.TabPanel);


Ext.reg('appmainpanel', MainPanel);
