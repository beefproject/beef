//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

ZombieTab = function(zombie) {
	main_tab = new ZombieTab_DetailsTab(zombie);
	log_tab = new ZombieTab_LogTab(zombie);
	commands_tab = new ZombieTab_Commands(zombie);
	requester_tab = new ZombieTab_Requester(zombie);
    xssrays_tab =  new ZombieTab_XssRaysTab(zombie);
    ipec_tab = new ZombieTab_IpecTab(zombie);
    autorun_tab = new ZombieTab_Autorun(zombie);
	ZombieTab.superclass.constructor.call(this, {
        id:"current-browser",
		activeTab: 0,
		loadMask: {msg:'Loading browser...'},
        title: "Current Browser",
		autoScroll: true,
		closable: false,
		viewConfig: {
			forceFit: true,
			type: 'fit'
		},
		items:[main_tab, log_tab, commands_tab, requester_tab, xssrays_tab, ipec_tab, autorun_tab],
        listeners:{
            afterrender:function(component){
                // Hide auto-run tab
                component.hideTabStripItem(autorun_tab);
            }
        }
	});
};

Ext.extend(ZombieTab, Ext.TabPanel, {
	listeners: {
        activate: function(panel) {},
        deactivate: function(panel) {},
		close: function(panel) {}
	}
});
