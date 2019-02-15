//
// Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
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
    autoLoad: false,
    proxy: new Ext.data.HttpProxy({
      method: 'GET',
      url: url + '?token=' + token
    }),
    storeId: 'zombies-store',
    baseParams: this.base,
    idProperty: 'id',
    fields: ['id','ip','domain','port','name','version', 'os', 'os_version', 'firstseen', 'lastseen'],
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
			}
		}
  });
};

Ext.extend(ZombieDataGrid, Ext.grid.GridPanel, {});

Ext.override(Ext.PagingToolbar, {
	doRefresh: function() {
		delete this.store.lastParams;
		this.doLoad(this.cursor);
	}
});
