//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The main Tab panel for the selected zombie.
 */
ZombieTab_DetailsTab = function(zombie) {
	
	var store_summary = new Ext.data.GroupingStore({
			url: '/ui/modules/select/zombie_summary.json',
			baseParams: {zombie_session: zombie.session} ,
			reader: new Ext.data.JsonReader({
					root: 'results'
				},[
					{name: 'data'},
					{name: 'category'},
					{name: 'from'}
				]),
			
			autoLoad: false,
			sortInfo:{field: 'from', direction: "ASC"},
			groupField:'category'
		});
	
	var grid_summary = new Ext.grid.GridPanel({
			store: store_summary,
			border: false,
			region: 'center',
			layout: 'fit',
			hideHeaders: true,
			loadMask: {msg:'Loading Information...'},
			
			view: new Ext.grid.GroupingView({
				forceFit:true,
				groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})',
				emptyText: "No Record found: this tab gets populated after you've ran some command modules.",
				enableRowBody:true
			}),
				
			viewConfig: {
				forceFit:true
			},
				
			columns:[
					{
						header: 'information',
						dataIndex: 'data',
						renderer: function(value, p, record) {
							html = '';
							
							for(index in value) {
								result = value[index];
								index = index.toString().replace('_', ' ');
								
								html += String.format('<b>{0}</b>: {1}<br>', index, $jEncoder.encoder.encodeForHTML(result));
							}
							
							return html;
						}
					},
					
					{header: 'command_module', dataIndex:'from', width: 25, renderer: function(value){return $jEncoder.encoder.encodeForHTML(value);}},
					{header: 'Category', dataIndex:'category', hidden: true, renderer: function(value){return $jEncoder.encoder.encodeForHTML(value);}}
				]
		});
	
	ZombieTab_DetailsTab.superclass.constructor.call(this, {
		id: 'zombie-details-tab'+zombie.session,
		layout: 'fit',
		title: 'Details',
		
		items: {
			layout:'border',
			border: false,
			items:[grid_summary]
		},
		
		listeners:{
			activate : function(maintab){
				maintab.items.items[0].items.items[0].store.reload();
			}
		}
	});
	
};

Ext.extend(ZombieTab_DetailsTab, Ext.Panel, {});
