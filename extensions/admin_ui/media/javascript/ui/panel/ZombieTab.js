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
ZombieTab = function(zombie) {
	
	main_tab = new ZombieTab_DetailsTab(zombie);
	log_tab = new ZombieTab_LogTab(zombie);
	commands_tab = new ZombieTab_Commands(zombie);
	requester_tab = new ZombieTab_Requester(zombie);
    xssrays_tab =  new ZombieTab_XssRaysTab(zombie);
	
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
		items:[main_tab, log_tab, commands_tab, requester_tab, xssrays_tab]
	});
	
};

Ext.extend(ZombieTab, Ext.TabPanel, {
	listeners: {
		close: function(panel) {
			panel.destroy();
		}
	}
});
