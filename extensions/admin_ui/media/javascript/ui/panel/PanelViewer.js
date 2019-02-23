//
// Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
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
 * This event updater retrieves zombie updates every periodically.
 * The poll timer is specified in befe.extension.admin_ui.panel_update_interval
 * These updates are then pushed to various managers (i.e. the zombie manager).
 */
var lastpoll = new Date().getTime();

Ext.TaskMgr.start({
	run: function() {
		Ext.Ajax.request({
			url: '/api/hooks/?token=' + beefwui.get_rest_token(),
			method: 'GET',
			success: function(response) {
				var updates;
				try {
					updates = Ext.util.JSON.decode(response.responseText);
				} catch (e) {
					//The framework has probably been reset and you're actually logged out
					var hr = document.getElementById("header-right");
					hr.innerHTML = "You appear to be logged out. <a href='<%= @base_path %>/panel/'>Login</a>";
				}
				var hooked_browsers = (updates['hooked-browsers']) ? updates['hooked-browsers'] : null;
				
				if(zombiesManager && hooked_browsers) {
					zombiesManager.updateZombies(hooked_browsers);
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
	
	interval: <%= (BeEF::Core::Configuration.instance.get("beef.extension.admin_ui.panel_update_interval") || 10).to_i * 1_000 %>
});
