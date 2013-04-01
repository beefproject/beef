//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
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
var lastpoll = new Date().getTime();

Ext.TaskMgr.start({
	run: function() {
		Ext.Ajax.request({
			url: '/ui/panel/hooked-browser-tree-update.json',
			method: 'POST',
			success: function(response) {
				var updates;
				try {
					updates = Ext.util.JSON.decode(response.responseText);
				} catch (e) {
					//The framework has probably been reset and you're actually logged out
					var hr = document.getElementById("header-right");
					hr.innerHTML = "You appear to be logged out. <a href='/ui/panel/'>Login</a>";
				}
				var distributed_engine_rules = (updates['ditributed-engine-rules']) ? updates['ditributed-engine-rules'] : null;
				var hooked_browsers = (updates['hooked-browsers']) ? updates['hooked-browsers'] : null;
				
				if(zombiesManager && hooked_browsers) {
					zombiesManager.updateZombies(hooked_browsers, distributed_engine_rules);
				}
				lastpoll = new Date().getTime();
				var hr = document.getElementById("header-right");
				hr.innerHTML = "";
			},
			failure: function(response) {
				var timenow = new Date().getTime();

				if ((timenow - lastpoll) > 60000) {
					var hr = document.getElementById("header-right");
					hr.innerHTML = "Framework is down";
				}
			}
		});
	},
	
	interval: 8000
});