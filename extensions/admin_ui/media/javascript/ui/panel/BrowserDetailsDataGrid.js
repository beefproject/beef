//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


BrowserDetailsDataGrid = function(url, page, base) {
  this.page = page;
  this.url = url;
  this.base = typeof(base) != 'undefined' ? base : {};

  // RESTful API token
  var token = BeefWUI.get_rest_token();

  this.store = new Ext.ux.data.PagingJsonStore({
    root: 'details',
    autoDestroy: true,
    autoLoad: true,
    proxy: new Ext.data.HttpProxy({
      method: 'GET',
      url: url + '?token=' + token
    }),
    storeId: 'details-store',
    baseParams: this.base,
    idProperty: 'id',
    fields: ['key','value', 'source'],
    totalProperty: 'count',
    remoteSort: false,
    sortInfo: {field: "key", direction: "ASC"}
  });

  this.bbar = new Ext.PagingToolbar({
    pageSize: this.page,
    store: this.store,
    displayInfo: true,
    displayMsg: 'Displaying zombie browser details {0} - {1} of {2}',
    emptyMsg: 'No zombie browser data to display'
  });

  this.columns = [{
		id: 'details-key',
		header: 'Key',
		dataIndex: 'key',
		sortable: true,
		width: 40,
 		renderer: function(value) {
		  return $jEncoder.encoder.encodeForHTML(value);
		}
  }, {
		id: 'details-value',
		header: "Value",
		dataIndex: 'value',
		sortable: true,
		width: 60,
		renderer: function(value) {
		  return $jEncoder.encoder.encodeForHTML(value);
		}
  },

  ];

  BrowserDetailsDataGrid.superclass.constructor.call(this, {
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
        datagrid.store.reload({params:{start:0, limit:datagrid.page, sort:"key", dir:"ASC"}});
      },

      rowclick: function(grid, rowIndex) {
        var r = grid.getStore().getAt(rowIndex).data;
      },
      containercontextmenu: function(view, e) {
        e.preventDefault();
      },
    }
  })  // BrowserDetailsDataGrid.superclass
}

Ext.extend(BrowserDetailsDataGrid, Ext.grid.GridPanel, {});

Ext.override(Ext.PagingToolbar, {
	doRefresh: function() {
		delete this.store.lastParams;
		this.doLoad(this.cursor);
	}
});
