//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * The zombie panel located on the left hand side of the interface.
 */
zombiesTreeList = function(id) {
    
	var title = id.slice(0,1).toUpperCase() + id.slice(1);

	zombiesTreeList.superclass.constructor.call(this, {
		id:'zombie-tree-'+id,
        region:'west',
        title: title,
        split:true,
        rootVisible:false,
        lines:false,
        autoScroll:true,
		useArrows:true,
        root: new Ext.tree.TreeNode('My Zombies'),
        collapseFirst:false
	});
	
	//the tree node that contains the list of online hooked browsers
	this.online_hooked_browsers_treenode = this.root.appendChild(
        new Ext.tree.TreeNode({
            qtip: "Online hooked browsers",
            text:'Online Browsers',
            cls:'online-zombies-node',
            expanded:true
        })
    );
	
	//the tree node that contains the list of offline hooked browsers
	this.offline_hooked_browsers_treenode = this.root.appendChild(
        new Ext.tree.TreeNode({
            qtip: "Offline hooked browsers",
            text:'Offline Browsers',
            cls:'offline-zombies-node',
            expanded:false
        })
    );
	
};

/*
 * The Tree panel that contains the zombie list.
 */
Ext.extend(zombiesTreeList, Ext.tree.TreePanel, {
	
	//saves the configuration for the tree
	tree_configuration: {
		'sub-branch' : 'domain',
		'distributed' : false
	},
	
	//store the list of online hooked browsers in an array
	online_hooked_browsers_array: new Array,
	
	//store the list of offline hooked browsers in an array
	offline_hooked_browsers_array: new Array,
	
	//store the distributed engine rules
	distributed_engine_rules: null,

    //add a context menu that will contain common action shortcuts for HBs
    contextMenu: new Ext.menu.Menu({
          items: [{
                        id: 'use_as_proxy',
                        text: 'Use as Proxy',
                        iconCls: 'zombie-tree-ctxMenu-proxy'
                    },{
                        id: 'xssrays_hooked_domain',
                        text: 'Launch XssRays on Hooked Domain',
                        iconCls: 'zombie-tree-ctxMenu-xssrays'
                    }

          ],
          listeners: {
              itemclick: function(item, object) {
                  var hb_id = this.contextNode.id.split('zombie-online-')[1];
                  switch (item.id) {
                      case 'use_as_proxy':
                           Ext.Ajax.request({
                                url: '/ui/proxy/setTargetZombie',
                                method: 'POST',
                                params: 'hb_id=' + escape(hb_id)
                            });
                          break;
                       case 'xssrays_hooked_domain':
                           Ext.Ajax.request({
                                url: '/ui/xssrays/set_scan_target',
                                method: 'POST',
                                params: 'hb_id=' + escape(hb_id)
                            });
                          break;
                  }
              }
          }
      }),
	
	listeners: {
		//creates a new hooked browser tab when a hooked browser is clicked
		click: function(node, e) {
			if(!node.leaf) return;

            mainPanel.remove(mainPanel.getComponent('current-browser'));
			if(!mainPanel.getComponent('current-browser')) {
				mainPanel.add(new ZombieTab(node.attributes));
			}
			
			mainPanel.activate(mainPanel.getComponent('current-browser'));
		},
        //show the context menu when a HB is right-clicked
        contextmenu: function(node, event){
                if(!node.leaf) return;

                node.select();
                var c = node.getOwnerTree().contextMenu;
                c.contextNode = node;
                c.showAt(event.getXY());

        },
		//update the set of rules when a checkbox is clicked
		checkchange: function(node, checked) {
			
		}
	},
	
	/*
	 * Updates the configuration of the tree.
	 * @param: {Literal Object} the new configuration.
	 */
	updateConfiguration: function(new_configuration) {
		Ext.apply(this.tree_configuration, new_configuration);
	},
	
	/*
	 * Reloads the tree. This function is useful after you have updated the configuration
	 * of the tree.
	 */
	reload: function() {
		//deletes all the nodes in the online hooked browser branch
		try {this.online_hooked_browsers_treenode.removeAll(true);} catch(e) {};
		
		//adds back the hooked browser to the online branch
		Ext.each(this.online_hooked_browsers_array, function(online_hooked_browser) {
			this.addZombie(online_hooked_browser, online_hooked_browser["online"], online_hooked_browser["checkbox"]);
		}, this)
		
		//expands the online hooked browser branch
		if(this.online_hooked_browsers_treenode.childNodes.length > 0)
			this.online_hooked_browsers_treenode.expand(true);
		
		//deletes all the nodes in the offline hooked browser branch
		try {this.offline_hooked_browsers_treenode.removeAll(true);} catch(e) {};
		
		//adds back the hooked browsers to the offline branch
		Ext.each(this.offline_hooked_browsers_array, function(offline_hooked_browser) {
			this.addZombie(offline_hooked_browser, offline_hooked_browser["online"], offline_hooked_browser["checkbox"]);
		}, this)
		
		//expands the online hooked browser branch
		if(this.offline_hooked_browsers_treenode.childNodes.length > 0)
			this.offline_hooked_browsers_treenode.expand(true);
	},
	
	/*
	 * Adds a new hooked browser to the tree.
	 * @param: {Literal Object} the hooked browser object generated by the zombie manager.
	 * @param: {Boolean} true if the hooked browser is online, false if offline.
	 * 
	 */
    addZombie: function(hooked_browser, online, checkbox) {
		var hb_id, mother_node, node;

		if(online) {
			hb_id = 'zombie-online-' + hooked_browser.session;
			mother_node = this.online_hooked_browsers_treenode;
		} else {
			hb_id = 'zombie-offline-' + hooked_browser.session;
			mother_node = this.offline_hooked_browsers_treenode;
		}
		var exists = this.getNodeById(hb_id);
		if(exists) return;

		hooked_browser.qtip = hooked_browser.balloon_text;

		//save a new online HB
		if(online && Ext.pluck(this.online_hooked_browsers_array, 'session').indexOf(hooked_browser.session)==-1) {
			this.online_hooked_browsers_array.push(hooked_browser);
		}
		
		//save a new offline HB
		if(!online && this.offline_hooked_browsers_array.indexOf(hooked_browser)==-1) {
			this.offline_hooked_browsers_array.push(hooked_browser);
		}
		
		//apply CSS styles and configuring the hooked browser for the tree
        Ext.apply(hooked_browser, {
            iconCls: 'feed-icon',
            leaf:true,
            id: hb_id,
			checked: ((checkbox) ? false : null),
			online: online,
			checkbox: checkbox
        });
        
		//creates a new node for that hooked browser
		node = new Ext.tree.TreeNode(hooked_browser);

		//creates a sub-branch for that HB if necessary
		mother_node = this.addSubFolder(mother_node, hooked_browser[this.tree_configuration['sub-branch']], checkbox);
		
		if(online) {
			//add the hooked browser to the online branch
			Ext.apply(hooked_browser, {cls: 'zombie-online'});
			mother_node.appendChild(node);
		} else {
			//add the hooked browser to the offline branch
			Ext.apply(hooked_browser, {cls: 'zombie-offline'});
			mother_node.appendChild(node);
		}
		
        return node;
    },

	/*
	 * Adds a sub-branch or sub-folder to the tree.
	 * @param: {Ext.tree.TreeNode} the mother node.
	 * @param: {String} the name of the new sub branch.
	 * @param: {Boolean} true if the sub-branch should have a checkbox; false if not.
	 */
	addSubFolder: function(mother_node, folder, checkbox) {
		if(!folder) return mother_node;
		
		if(mother_node.hasChildNodes()) {
			for(i in mother_node.childNodes) {
				node = mother_node.childNodes[i];
				
				if(typeof node == 'object' && node.attributes.text == folder)
					return node;
			}
		} else {
			sub_folder_node = new Ext.tree.TreeNode({
				id: 'sub-folder-'+folder,
				text: folder,
				qtip: "Browsers hooked on "+folder,
				checked: ((checkbox) ? false : null),
				type: this.tree_configuration["sub-branch"]
				});
			
			mother_node.appendChild(sub_folder_node);
			mother_node = sub_folder_node;
		}
		
		return mother_node;
	},
	
	/*
	 * Remove any duplicated hooked browsers in branches.
	 * @param: {Literal Object} object containing the list of hooked browsers.
	 */
	compareAndRemove: function(zombies) {
		
		var arr = ['online', 'offline'];
		var has_changed = false;
		
		Ext.each(arr, function(branch_type) {
			var new_set_zombies = zombies[branch_type];
			var new_set_zombies_array = new Array;
			
			//converts the new set of zombies to an array
			Ext.iterate(new_set_zombies, function(key, hooked_browser) { new_set_zombies_array.push(hooked_browser); });
			
			//retrieves all the new hooked browsers' session id
			var new_set_zombies_sessions = Ext.pluck(new_set_zombies_array, 'session');
			if(!new_set_zombies_sessions) return;
			
			//retrieves the branch that will be updated
			var branch_node = eval('this.'+branch_type+'_hooked_browsers_treenode');
			
			//retrieves the list of known hooked browsers in that branch
			var hooked_browser_array = eval('this.'+branch_type+'_hooked_browsers_array');
			if(hooked_browser_array.length == 0) return;
			
			//we compare the list of known HBs to the new set of HBs retrieved. If a HB is missing
			//we delete it from the tree.
			Ext.iterate(hooked_browser_array, function(known_hooked_browser, key) {
				if(!known_hooked_browser) return;
				
				var hb_session = known_hooked_browser["session"];
				
				if(new_set_zombies_sessions.indexOf(hb_session)==-1) {
					var node = this.getNodeById('zombie-'+branch_type+'-'+hb_session);
					if(node) {
						//remove the node from the tree
						branch_node.removeChild(node);

                        var parentNode = node.parentNode;
                        // remove the node parent sub-folder only if there are not any other HBs as child of it
                        // (basically, zombies that comes from the same IP)
                        if(parentNode.childNodes.length <= 1){
                            branch_node.removeChild(parentNode);
                        }

						//because ExtJs has a bug with node.destroy() this is a hack to make it work for beef.
						node.setId("hooked-browser-node-destroyed");
						
						//update the array of hooked browser
						hooked_browser_array = hooked_browser_array.slice(key, key+1);
						eval('this.'+branch_type+'_hooked_browsers_array = hooked_browser_array');
					}
				}

				// if a HB is in both the node list and the new list - check its ip is still correct - and if not update it
				if(new_set_zombies_sessions.indexOf(hb_session)!=-1) {
					Ext.iterate(new_set_zombies, function(key, new_zombie) {
						if (new_zombie.session == known_hooked_browser.session && new_zombie.ip != known_hooked_browser.ip) {
							known_hooked_browser.ip = new_zombie.ip;
							known_hooked_browser.domain = new_zombie.ip;
                            known_hooked_browser.port=new_zombie.port;
							known_hooked_browser.text = known_hooked_browser.text.replace(/\d*\.\d*\.\d*\.\d*/gi, new_zombie.ip);
							has_changed = true;
						}
	                });
				}
			}, this);
		}, this);
		
		// if an ip change was made - reload the try to show the change
	    if (has_changed) {
			this.reload();
		}
	},
	
	/*
	 * Apply a new set of distributed engine rules to the nodes in the tree
	 * @param: {Literal Objects} the rules set. See the zombie manager.
	 */
	applyRules: function(rules) {
		//we return if the tree is not distributed
		if(!this.tree_configuration["distributed"]) return;
		
	}
});
