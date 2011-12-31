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

