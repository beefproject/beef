ZombieTab = function(zombie) {
	
	main_tab = new ZombieTab_DetailsTab(zombie);
	log_tab = new ZombieTab_LogTab(zombie);
	commands_tab = new ZombieTab_Commands(zombie);
	requester_tab = new ZombieTab_Requester(zombie);
	
	//-------------------------------------------
	ZombieTab.superclass.constructor.call(this, {
		id: zombie.session,
		activeTab: 0,
		loadMask: {msg:'Loading browser...'},
		title: zombie.ip,
		autoScroll: true,
		closable: true,
		viewConfig: {
			forceFit: true,
			type: 'fit'
		},
		items:[main_tab, log_tab, commands_tab, requester_tab]
	});
	
};

Ext.extend(ZombieTab, Ext.TabPanel, {
	listeners: {
		close: function(panel) {
			panel.destroy();
		}
	}
});
