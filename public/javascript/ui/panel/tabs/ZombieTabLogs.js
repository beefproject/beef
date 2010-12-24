/*
 * The log Tab panel for the selected zombie.
 */
ZombieTab_LogTab = function(zombie) {

	var zombieLog = new DataGrid('/ui/logs/zombie.json',30,{session:zombie.session});
	zombieLog.border = false;

	ZombieTab_LogTab.superclass.constructor.call(this, {
		id: 'zombie-log-tab' + zombie.session,
		layout: 'fit',
		title: 'Logs',
		items: {
			layout: 'border',
			border: false,
			items:[zombieLog]
		}
	});
};

Ext.extend(ZombieTab_LogTab, Ext.Panel, {} );

