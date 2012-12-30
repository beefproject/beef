//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The XssRays Tab panel for the selected zombie.
 */

//TODO: fix positioning issues, probably because we are not creating a nested (fucking) panel
ZombieTab_XssRaysTab = function(zombie) {

	var commands_statusbar = new Beef_StatusBar('xssrays-bbar-zombie-'+zombie.session);

     var req_pagesize = 30;

    var xssrays_config_panel = new Ext.Panel({
		id: 'xssrays-config-zombie-'+zombie.session,
		title: 'Scan Config',
		layout: 'fit'
	});

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
            {header: 'Vector Method', width: 30, sortable: true, dataIndex: 'vector_method', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
            {header: 'Vector Name', width: 40, sortable: true, dataIndex: 'vector_name', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}},
            {header: 'Vector PoC', sortable: true, dataIndex: 'vector_poc', renderer: function(value){return $jEncoder.encoder.encodeForHTML(value)}}
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

    function genScanSettingsPanel(zombie, bar, value) {
		var form = new Ext.FormPanel({
			title: 'Scan settings',
			id: 'xssrays-config-form-zombie'+zombie.session,
			url: '/ui/xssrays/createNewScan',
            labelWidth: 230,
			border: false,
			padding: '3px 5px 0 5px',
            defaults: {width: 100},
            defaultType: 'textfield',

			items:[{
                fieldLabel: 'Clean Timeout (milliseconds before the injected iFrames are removed from the DOM)',
                name: 'clean_timeout',
                allowBlank:false,
                value: 5000,
                padding: '10px 5px 0 5px'
            },{
               xtype:'checkbox',
               fieldLabel: 'Cross-domain (check for XSS on cross-domain resources)',
               name: 'cross_domain',
               checked: true
            }],

			buttons: [{
				text: 'Start Scan',
				handler: function() {
					var form = Ext.getCmp('xssrays-config-form-zombie'+zombie.session).getForm();

                    bar.update_sending('Saving settings and ready to start XssRays... ' + zombie.ip + '...');

					form.submit({
						params: {
							nonce: Ext.get("nonce").dom.value,
							zombie_session: zombie.session
						},
						success: function() {
							bar.update_sent("Scan settings saved for hooked browser [" + zombie.ip + "]. XssRays will be added to victim DOM on next polling.");
						},
						failure: function() {
							bar.update_fail("Error! Something went wrong saving scan settings.");
						}
					});
				}
			}]
		});

		panel = Ext.getCmp('xssrays-config-zombie-'+zombie.session);
		panel.setTitle('Scan Config');
		panel.add(form);
	}

	ZombieTab_XssRaysTab.superclass.constructor.call(this, {
        id: 'xssrays-log-tab-'+zombie.session,
		title: 'XssRays',
		activeTab: 0,
		viewConfig: {
			forceFit: true,
			type: 'fit'
		},
        items: [xssrays_logs_panel, xssrays_config_panel],
        bbar: commands_statusbar,
        listeners: {
			afterrender : function(){
				genScanSettingsPanel(zombie, commands_statusbar);
			}
		}
	});
};

Ext.extend(ZombieTab_XssRaysTab, Ext.TabPanel, {} );