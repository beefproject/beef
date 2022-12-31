//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


ZombieDataGrid = function(url, page, base) {
  this.page = page;
  this.url = url;
  this.base = typeof(base) != 'undefined' ? base : {};

  // RESTful API token
  var token = BeefWUI.get_rest_token();

  this.store = new Ext.ux.data.PagingJsonStore({
    root: 'zombies',
    autoDestroy: true,
    autoLoad: true,
    proxy: new Ext.data.HttpProxy({
      method: 'GET',
      url: url + '?token=' + token
    }),
    storeId: 'zombies-store',
    baseParams: this.base,
    idProperty: 'id',
    fields: ['id','session', 'ip','domain','port','name','version', 'os', 'os_version', 'firstseen', 'lastseen'],
    totalProperty: 'count',
    remoteSort: false,
    sortInfo: {field: "id", direction: "ASC"}
  });

  this.bbar = new Ext.PagingToolbar({
    pageSize: this.page,
    store: this.store,
    displayInfo: true,
    displayMsg: 'Displaying zombies {0} - {1} of {2}',
    emptyMsg: 'No zombies to display'
  });

  this.columns = [{
		id: 'zombie-id',
		header: 'ID',
		hidden: false,
		dataIndex: 'id',
		sortable: true,
		width: 10
  }, {
		id: 'zombie-session',
		header: "Session",
		dataIndex: 'session',
		sortable: true,
    hidden: true,
		width: 20,
		renderer: function(value) {
		  return $jEncoder.encoder.encodeForHTML(value);
		}
  }, {
		id: 'zombie-ip',
		header: "IP",
		dataIndex: 'ip',
		sortable: true,
		width: 20,
		renderer: function(value) {
		  return $jEncoder.encoder.encodeForHTML(value);
		}
  }, {
		id: 'zombie-domain',
		header: "Domain",
		dataIndex: 'domain',
		sortable: true,
		width: 20,
		renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(value);
    }
  }, {
		id: 'zombie-port',
		header: "Port",
		dataIndex: 'port',
		sortable: true,
		width: 20,
		renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(value);
    },
  }, {
		id: 'zombie-browser_name',
		header: "Browser",
		dataIndex: 'name',
		sortable: true,
		width: 20,
		renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(value);
    }
	}, {
		id: 'zombie-browser_version',
		header: "Browser Version",
		dataIndex: 'version',
		sortable: true,
		width: 20,
		renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(value);
    }
  }, {
    id: 'zombie-os',
    header: "OS",
    dataIndex: 'os',
    sortable: true,
    width: 20,
    renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(value);
    }
  }, {
    id: 'zombie-os_version',
    header: "OS Version",
    dataIndex: 'os_version',
    sortable: true,
    width: 20,
    renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(value);
    }
  }, {
    id: 'zombie-first_seen',
    header: "First Seen",
    dataIndex: 'firstseen',
    sortable: true,
    width: 25,
    renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(new Date(1000*value).toUTCString());
    }
  }, {
    id: 'zombie-last_seen',
    header: "Last Seen",
    dataIndex: 'lastseen',
    sortable: true,
    width: 25,
    renderer: function(value){
      return $jEncoder.encoder.encodeForHTML(new Date(1000*value).toUTCString());
    }
  },

  ];

  ZombieDataGrid.superclass.constructor.call(this, {
    region: 'center',
    id: 'topic-grid',
    loadMask: {msg:'Loading Feed...'},

    sm: new Ext.grid.RowSelectionModel({
      singleSelect: true
    }),

    viewConfig: {
      forceFit: true
    },
    listeners: {
      afterrender: function(datagrid) {
        datagrid.store.reload({params:{start:0, limit:datagrid.page, sort:"id", dir:"ASC"}});
      },

      rowclick: function(grid, rowIndex) {
        var r = grid.getStore().getAt(rowIndex).data;
      },
      containercontextmenu: function(view, e) {
        e.preventDefault();
      },
      rowcontextmenu: function(grid, rowIndex, e) {
        e.preventDefault();
        grid.getSelectionModel().selectRow(rowIndex);

        if (!!grid.rowCtxMenu) {
          grid.rowCtxMenu.destroy();
        }
        //var record = grid.selModel.getSelected();
        grid.rowCtxMenu = new Ext.menu.Menu({
          //add a context menu that will contain common action shortcuts for HBs
          items: <%=
  context_menu = []
  sep = { xtype: 'menuseparator' }

  if (BeEF::Core::Configuration.instance.get("beef.extension.proxy.enable"))
    context_menu << {
      id: 'zombie_grid_use_as_proxy',
      text: 'Use as Proxy',
      iconCls: 'zombie-tree-ctxMenu-proxy'
    }
    context_menu << sep
  end
  if (BeEF::Core::Configuration.instance.get("beef.extension.xssrays.enable"))
    context_menu << {
      id: 'zombie_grid_xssrays_hooked_domain',
      text: 'Launch XssRays on Hooked Domain',
      iconCls: 'zombie-tree-ctxMenu-xssrays'
    }
    context_menu << sep
  end
  if (BeEF::Core::Configuration.instance.get("beef.extension.webrtc.enable"))
    context_menu << {
      id: 'zombie_grid_rtc_caller',
      text: 'Set as WebRTC Caller',
      iconCls: 'zombie-tree-ctxMenu-rtc'
    }
    context_menu << {
      id: 'zombie_grid_rtc_receiver',
      text: 'Set as WebRTC Receiver and GO',
      iconCls: 'zombie-tree-ctxMenu-rtc',
      activated: false
    }
    context_menu << sep
  end

  context_menu << {
    id: 'zombie_grid_delete_zombie',
    text: 'Delete Zombie',
    iconCls: 'zombie-tree-ctxMenu-delete'
  }

  context_menu.to_json
%>,

          listeners: {
            itemclick: function(item, object) {
              var record = grid.selModel.getSelected();
              var hb_id = record.get('session');
              switch (item.id) {
              case 'zombie_grid_use_as_proxy':
                Ext.Ajax.request({
                  url: '/api/proxy/setTargetZombie?token=' + beefwui.get_rest_token(),
                  method: 'POST',
                  headers: {'Content-Type': 'application/json; charset=UTF-8'},
                  jsonData: {'hb_id': escape(hb_id)}
                });
                break;
              case 'zombie_grid_xssrays_hooked_domain':
                Ext.Ajax.request({
                  url: '/api/xssrays/scan/' + escape(hb_id) + '?token=' + beefwui.get_rest_token(),
                  method: 'POST'
                });
                break;
              case 'zombie_grid_rtc_caller':
                beefwui.rtc_caller = hb_id;
                break;
              case 'zombie_grid_rtc_receiver':
                beefwui.rtc_receiver = hb_id;
                var url = "/api/webrtc/go?token=" + beefwui.get_rest_token();
                Ext.Ajax.request({
                  url: url,
                  method: 'POST',
                  headers: {'Content-Type': 'application/json; charset=UTF-8'},
                  jsonData: {
                    'from': beefwui.get_hb_id(beefwui.rtc_caller),
                    'to': beefwui.get_hb_id(beefwui.rtc_receiver),
                    'verbose': true
                  }
                });
                break;
              case 'zombie_grid_delete_zombie':
                var token = beefwui.get_rest_token();
                if (!confirm('Are you sure you want to delete zombie [id: ' + hb_id + '] ?\nWarning: this will remove all zombie related data, including logs and command results!')) {
                  //commands_statusbar.update_fail('Cancelled');
                  return;
                }
                //commands_statusbar.update_sending('Removing zombie [id: ' + hb_id + '] ...');
                var url = "/api/hooks/" + escape(hb_id) + "/delete?token=" + token;
                Ext.Ajax.request({
                  url: url,
                  method: 'GET'
                });
                break;

              }
            }
          }
        });
        grid.rowCtxMenu.showAt(e.getXY());
      }
      }
  })  // ZombieDataGrid.superclass
}

Ext.extend(ZombieDataGrid, Ext.grid.GridPanel, {});

Ext.override(Ext.PagingToolbar, {
	doRefresh: function() {
		delete this.store.lastParams;
		this.doLoad(this.cursor);
	}
});
