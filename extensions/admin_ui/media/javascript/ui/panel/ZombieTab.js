//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

ZombieTab = function(zombie) {
	main_tab = new ZombieTab_DetailsTab(zombie);
	log_tab = new ZombieTab_LogTab(zombie);
	commands_tab = new ZombieTab_Commands(zombie);
	proxy_tab = new ZombieTab_Requester(zombie);
	xssrays_tab =  new ZombieTab_XssRaysTab(zombie);
	network_tab = new ZombieTab_Network(zombie);
	webrtc_tab = new ZombieTab_Rtc(zombie);

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
    items:[
      main_tab,
      log_tab,
      commands_tab,
      proxy_tab,
      xssrays_tab,
      network_tab,
      webrtc_tab
    ],
		listeners:{
			afterrender:function(component){
        // Hide tabs for disabled functionality
        <%= BeEF::Core::Configuration.instance.get("beef.extension.webrtc.enable") ? '' : 'component.hideTabStripItem(webrtc_tab);' %>
        <%= BeEF::Core::Configuration.instance.get("beef.extension.xssrays.enable") ? '' : 'component.hideTabStripItem(xssrays_tab);' %>
        <%= BeEF::Core::Configuration.instance.get("beef.extension.network.enable") ? '' : 'component.hideTabStripItem(network_tab);' %>
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
