//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The log Tab panel for the selected zombie.
 */
ZombieTab_LogTab = function(zombie) {

	var zombieLog = new LogsDataGrid('/api/logs/' + zombie.session ,30);
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

