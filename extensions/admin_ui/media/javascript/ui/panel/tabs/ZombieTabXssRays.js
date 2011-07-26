//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
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
 * The XssRays Tab panel for the selected zombie.
 */

//TODO: fix positioning issues, probably because we are not creating a nested (fucking) panel
ZombieTab_XssRaysTab = function(zombie) {

	var commands_statusbar = new Beef_StatusBar('xssrays-bbar-zombie-'+zombie.session);

     var req_pagesize = 30;

     var xssrays_logs_store = new Ext.ux.data.PagingJsonStore({
        storeId: 'xssrays-logs-store-zombie-' + zombie.session,
        url: '/ui/xssrays/zombie.json',
        remoteSort: false,
        autoDestroy: true,
        autoLoad: false,
        root: 'logs',

        fields: ['id', 'vector_method', 'vector_name', 'vector_poc'],
        sortInfo: {field: 'id', direction: 'DESC'},

        baseParams: {
            nonce: Ext.get("nonce").dom.value,
            zombie_session: zombie.session
        }
    });

    var xssrays_logs_bbar = new Ext.PagingToolbar({
        pageSize: req_pagesize,
        store: xssrays_logs_store,
        displayInfo: true,
        displayMsg: 'Displaying history {0} - {1} of {2}',
        emptyMsg: 'No history to display'
    });

    var xssrays_logs_grid = new Ext.grid.GridPanel({
        id: 'xssrays-logs-grid-zombie-' + zombie.session,
        store: xssrays_logs_store,
        bbar: xssrays_logs_bbar,
        border: false,
        loadMask: {msg:'Loading History...'},

        viewConfig: {
            forceFit:true
        },

        view: new Ext.grid.GridView({
            forceFit: true,
            emptyText: "No History",
            enableRowBody:true
        }),

        columns: [
            {header: 'Id', width: 10, sortable: true, dataIndex: 'id', hidden:true},
            {header: 'Vector Method', width: 30, sortable: true, dataIndex: 'vector_method'},
            {header: 'Vector Name', width: 40, sortable: true, dataIndex: 'vector_name'},
            {header: 'Vector PoC', sortable: true, dataIndex: 'vector_poc'}
        ],

        listeners: {
            afterrender: function(datagrid) {
                datagrid.store.reload({params:{start:0,limit:req_pagesize, sort: "date", dir:"DESC"}});
            }
        }
    });

    var xssrays_logs_panel = new Ext.Panel({
		id: 'xssrays-logs-panel-zombie-'+zombie.session,
		title: 'Logs',
		items:[xssrays_logs_grid],
		layout: 'fit',

		listeners: {
			activate: function(xssrays_logs_panel) {
				xssrays_logs_panel.items.items[0].store.reload();
			}
		}
	});

	ZombieTab_XssRaysTab.superclass.constructor.call(this, {
        id: 'xssrays-log-tab-'+zombie.session,
		title: 'XssRays',
		activeTab: 0,
		viewConfig: {
			forceFit: true,
			type: 'fit'
		},
        items: [xssrays_logs_panel],
        bbar: commands_statusbar
	});
};

Ext.extend(ZombieTab_XssRaysTab, Ext.Panel, {} );