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
