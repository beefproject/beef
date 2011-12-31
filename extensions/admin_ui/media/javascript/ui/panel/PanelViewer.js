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
PanelViewer = {};
var mainPanel, zombiesTreeLists, zombieTabs, zombiesManager;

Ext.onReady(function() {
	
	Ext.QuickTips.init();

	zombiesTreeLists = {
		'basic' : new zombiesTreeList('basic'),
		'requester' : new zombiesTreeList('requester')
	};
	
	zombieTabs = new ZombieTabs(zombiesTreeLists);
	zombiesManager = new ZombiesMgr(zombiesTreeLists);
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
});

/*
 * Panel Events Updater
 *
 * This event updater retrieves updates every 8 seconds. Those updates
 * are then pushed to various managers (i.e. the zombie manager).
 */
Ext.TaskMgr.start({
	run: function() {
		Ext.Ajax.request({
			url: '/ui/panel/hooked-browser-tree-update.json',
			method: 'POST',
			success: function(response) {
				var updates = Ext.util.JSON.decode(response.responseText);
				var distributed_engine_rules = (updates['ditributed-engine-rules']) ? updates['ditributed-engine-rules'] : null;
				var hooked_browsers = (updates['hooked-browsers']) ? updates['hooked-browsers'] : null;
				
				if(zombiesManager && hooked_browsers) {
					zombiesManager.updateZombies(hooked_browsers, distributed_engine_rules);
				}
			}
		});
	},
	
	interval: 8000
});