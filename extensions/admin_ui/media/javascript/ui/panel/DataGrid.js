//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


DataGrid = function(url, page, base) {
    this.page = page;
    this.url = url;
    this.base = typeof(base) != 'undefined' ? base : {};

    this.store = new Ext.ux.data.PagingJsonStore({
        root: 'logs',
        autoDestroy: true,
		autoLoad: false,
        url: this.url,
        storeId: 'myStore',
        baseParams: this.base,
        idProperty: 'id',
        fields: ['id','type','event','date','hooked_browser_id'],
        totalProperty: 'count',
        remoteSort: false,
        sortInfo: {field: "id", direction: "DESC"}
    });

    this.bbar = new Ext.PagingToolbar({
        pageSize: this.page,
	store: this.store,
        displayInfo: true,
        displayMsg: 'Displaying logs {0} - {1} of {2}',
        emptyMsg: 'No logs to display'
    });
	
    this.columns = [{
			id: 'log-id',
			header: 'Id',
			hidden: false,
			dataIndex: 'id',
			sortable: true,
			width: 20
		}, {
			id: 'log-type',
			header: "Type",
			dataIndex: 'type',
			sortable: true,
			width: 60,
			renderer: function(value, metaData, record, rowIndex, colIndex, store) {
				return "<b>" + $jEncoder.encoder.encodeForHTML(value) + "</b>";
			}
		}, {
			id: 'log-event',
			header: "Event",
			dataIndex: 'event',
			sortable:true,
			width: 420,
			renderer: $jEncoder.encoder.encodeForHTML(this.formatTitle)
		}, {
			id: 'log-date',
			header: "Date",
			dataIndex: 'date',
			width: 80,
			renderer:  $jEncoder.encoder.encodeForHTML(this.formatDate),
			sortable:true
		}, {
			id: 'log-browser',
			header: "Browser ID",
			dataIndex: 'hooked_browser_id',
			sortable: true,
			width: 35
    }];

    DataGrid.superclass.constructor.call(this, {
        region: 'center',
        id: 'topic-grid',
        loadMask: {msg:'Loading Feed...'},

        sm: new Ext.grid.RowSelectionModel({
            singleSelect:true
        }),

        viewConfig: {
            forceFit:true
        },
		
		listeners: {
			afterrender: function(datagrid) {
				datagrid.store.reload({params:{start:0, limit:datagrid.page, sort:"id", dir:"DESC"}});
			}
		}
    });
};

Ext.extend(DataGrid, Ext.grid.GridPanel, {});

//Because we're using paging stores now, we have to override the PagingToolbar refresh
Ext.override(Ext.PagingToolbar, {
	doRefresh: function() {
		delete this.store.lastParams;
		this.doLoad(this.cursor);
	}
});
