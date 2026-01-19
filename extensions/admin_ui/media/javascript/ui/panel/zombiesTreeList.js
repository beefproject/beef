//
// Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - https://beefproject.com
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
		'sub-branch' : 'domain'
	},

	//store the list of online hooked browsers in an array
	online_hooked_browsers_array: new Array,
	
	//store the list of offline hooked browsers in an array
	offline_hooked_browsers_array: new Array,
	
    //add a context menu that will contain common action shortcuts for HBs
    contextMenu: new Ext.menu.Menu({
      items: <%=
  context_menu = []
  sep = { xtype: 'menuseparator' }

  if (BeEF::Core::Configuration.instance.get("beef.extension.proxy.enable"))
    context_menu << {
      id: 'use_as_proxy',
      text: 'Use as Proxy',
      iconCls: 'zombie-tree-ctxMenu-proxy'
    }
    context_menu << sep
  end
  if (BeEF::Core::Configuration.instance.get("beef.extension.xssrays.enable"))
    context_menu << {
      id: 'xssrays_hooked_origin',
      text: 'Launch XssRays on Hooked Domain',
      iconCls: 'zombie-tree-ctxMenu-xssrays'
    }
    context_menu << sep
  end
  if (BeEF::Core::Configuration.instance.get("beef.extension.webrtc.enable"))
    context_menu << {
      id: 'rtc_caller',
      text: 'Set as WebRTC Caller',
      iconCls: 'zombie-tree-ctxMenu-rtc'
    }
    context_menu << {
      id: 'rtc_receiver',
      text: 'Set as WebRTC Receiver and GO',
      iconCls: 'zombie-tree-ctxMenu-rtc',
      activated: false
    }
    context_menu << sep
  end

  context_menu << {
    id: 'delete_zombie',
    text: 'Delete Zombie',
    iconCls: 'zombie-tree-ctxMenu-delete'
  }

  context_menu.to_json
%>,

          listeners: {
              itemclick: function(item, object) {
                  var hb_id = this.contextNode.id.split('-')[2];
                  switch (item.id) {
                      case 'use_as_proxy':
                           Ext.Ajax.request({
                                url: '/api/proxy/setTargetZombie?token=' + beefwui.get_rest_token(),
                                method: 'POST',
                                headers: {'Content-Type': 'application/json; charset=UTF-8'},
                                jsonData: {'hb_id': escape(hb_id)}
                            });
                          break;
                       case 'xssrays_hooked_origin':
                           Ext.Ajax.request({
                                url: '/api/xssrays/scan/' + escape(hb_id) + '?token=' + beefwui.get_rest_token(),
                                method: 'POST'
                            });
                          break;
                       case 'rtc_caller':
                          beefwui.rtc_caller = hb_id;
                          break;
                       case 'rtc_receiver':
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
                       case 'delete_zombie':
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
      }),
	
	listeners: {
		//creates a new hooked browser tab when a hooked browser is clicked
		click: function(node, e) {
            globalnode = node;
			if(!node.leaf) return;
      window.location.hash = "#id=" + node.attributes.session;
		},
        //show the context menu when a HB is right-clicked
        contextmenu: function(node, event){
                if(!node.leaf) return;

                node.select();
                // if (typeof(beefwui.rtc_caller) === 'undefined') {
                //     node.getOwnerTree().contextMenu.items.add({
                //         id: 'rtc_caller',
                //         text: 'Set as WebRTC Caller',
                //         iconCls: 'zombie-tree-ctxMenu-xssrays'
                //     });
                // }
                var c = node.getOwnerTree().contextMenu;
try{
                c.contextNode = node;
                if (typeof(beefwui.rtc_caller) === 'undefined') {
                    c.items.get('rtc_receiver').disable();
                } else if (beefwui.rtc_caller === node.id.substr(-80)) {
                    c.items.get('rtc_receiver').disable();
                } else {
                    c.items.get('rtc_receiver').enable();
                }
} catch(e) {
  // could not render the webrtc context menu - is webrtc extenion disabled?
}
                // c.items['rtc_receiver'].disable();
                // c.add({
                //     id: 'rtc_caller',
                //     text: 'Set as WebRTC Caller',
                //     iconCls: 'zombie-tree-ctxMenu-xssrays'});
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
		
		//expands the offline hooked browser branch
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

		// set zombie icons. this should eventually be replaced with CSS classes
		var browser_icon = 'unknown.png';
		switch (hooked_browser.browser_name) {
			case "FF":
				browser_icon = 'firefox.png';
				break;
			case "IE":
				browser_icon = 'msie.png';
				break;
			case "E":
				browser_icon = 'edge.png';
				break;
			case "EP":
				browser_icon = 'epiphany.png';
				break;
			case "S":
				browser_icon = 'safari.png';
				break;
			case "C":
				browser_icon = 'chrome.png';
				break;
			case "O":
				browser_icon = 'opera.ico';
				break;
			case "MI":
				browser_icon = 'midori.png';
				break;
			case "OD":
				browser_icon = 'odyssey.png';
				break;
			case "BR":
				browser_icon = 'brave.png';
				break;
			default:
				browser_icon = 'unknown.png';
				break;
		}

		var os_icon = 'unknown.png';
		switch (hooked_browser.os_name) {
			case "Android":
				os_icon = 'android.png';
				break;
			case "Windows":
				os_icon = 'win.png';
				break;
			case "Linux":
				os_icon = 'linux.png';
				break;
			case "Mac":
				os_icon = 'mac.png';
				break;
			case "QNX":
				os_icon = 'qnx.ico';
				break;
			case "SunOS":
				os_icon = 'sunos.gif';
				break;
			case "BeOS":
				os_icon = 'beos.png';
				break;
			case "OpenBSD":
				os_icon = 'openbsd.ico';
				break;
			case "iOS":
				os_icon = 'ios.png';
				break;
			case "iPhone":
				os_icon = 'iphone.jpg';
				break;
			case "iPad":
				os_icon = 'ipad.png';
				break;
			case "iPod":
				os_icon = 'ipod.jpg';
				break;
			case "webOS":
				os_icon = 'webos.png';
				break;
			case "AROS":
				os_icon = 'icaros.png';
				break;
			case "Maemo":
				os_icon = 'maemo.ico';
				break;
			case "BlackBerry":
				os_icon = 'blackberry.png';
				break;
			default:
				os_icon = 'unknown.png';
				break;
		}

		var hw_icon = 'unknown.png';
		switch (hooked_browser.hw_name) {
			case "Virtual Machine":
				hw_icon = 'vm.png';
				break;
			case "Laptop":
				hw_icon = 'laptop.png';
				break;
			case "Android":
				hw_icon = 'android.png';
				break;
			case "Android Phone":
				hw_icon = 'android.png';
				break;
			case "Android Tablet":
				hw_icon = 'android.png';
				break;
			case "iPhone":
				hw_icon = 'iphone.jpg';
				break;
			case "iPod Touch":
				hw_icon = 'ipod.jpg';
				break;
			case "iPad":
				hw_icon = 'ipad.png';
				break;
			case "BlackBerry":
				hw_icon = 'blackberry.png';
				break;
			case "BlackBerry Tablet":
				hw_icon = 'blackberry.png';
				break;
			case "BlackBerry Touch":
				hw_icon = 'blackberry.png';
				break;
			case "BlackBerry OS 5":
				hw_icon = 'blackberry.png';
				break;
			case "BlackBerry OS 6":
				hw_icon = 'blackberry.png';
				break;
			case "Nokia":
				hw_icon = 'nokia.ico';
				break;
			case "Nokia S60 Open Source":
				hw_icon = 'nokia.ico';
				break;
			case "Nokia S60":
				hw_icon = 'nokia.ico';
				break;
			case "Nokia S70":
				hw_icon = 'nokia.ico';
				break;
			case "Nokia S80":
				hw_icon = 'nokia.ico';
				break;
			case "Nokia S90":
				hw_icon = 'nokia.ico';
				break;
			case "Nokia Symbian":
				hw_icon = 'nokia.ico';
				break;
			case "Maemo Tablet":
				hw_icon = 'maemo.ico';
				break;
			case "HTC":
				hw_icon = 'htc.ico';
				break;
			case "Motorola":
				hw_icon = 'motorola.png';
				break;
			case "Zune":
				hw_icon = 'zune.gif';
				break;
			case "Kindle":
				hw_icon = 'kindle.png';
				break;
			case "Kindle Fire":
				hw_icon = 'kindle.png';
				break;
			case "Nexus":
				hw_icon = 'nexus.png';
				break;
			case "Google Nexus One":
				hw_icon = 'nexus.png';
				break;
			case "Ericsson":
				hw_icon = 'sony_ericsson.png';
				break;
			case "Windows Phone":
				hw_icon = 'win.png';
				break;
			case "Windows Phone 7":
				hw_icon = 'win.png';
				break;
			case "Windows Phone 8":
				hw_icon = 'win.png';
				break;
			case "Windows Phone 10":
				hw_icon = 'win.png';
				break;
			case "Windows Mobile":
				hw_icon = 'win.png';
				break;
			default:
				hw_icon = 'pc.png';
				break;
		}

		// set zombie hover balloon text for tree node
		// Use Ext.util.Format.htmlEncode() to prevent XSS via malicious browser properties
		var encode = Ext.util.Format.htmlEncode;
		var balloon_text = "";
		balloon_text += encode(hooked_browser.ip);
		balloon_text += "<hr/>"
		balloon_text += "<img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/favicon.png' /> ";
		balloon_text += "Origin: " + encode(hooked_browser.domain) + ":" + encode(hooked_browser.port);
		balloon_text += "<br/>";
		balloon_text += "<img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/" + escape(browser_icon) + "' /> ";
		balloon_text += "Browser: " + encode(hooked_browser.browser_name) + " " + encode(hooked_browser.browser_version);
		balloon_text += "<br/>";
		balloon_text += " <img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/" + escape(os_icon) + "' /> ";
		if (hooked_browser.os_version == 'Unknown') {
		  balloon_text += "OS: " + encode(hooked_browser.os_name);
		} else {
		  balloon_text += "OS: " + encode(hooked_browser.os_name) + ' ' + encode(hooked_browser.os_version);
		}
		balloon_text += "<br/>";
		balloon_text += " <img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/" + escape(hw_icon) + "' /> ";
		balloon_text += "Hardware: " + encode(hooked_browser.hw_name);
		balloon_text += "<br/>";

		if ( !hooked_browser.country || !hooked_browser.country_code || hooked_browser.country == 'Unknown' ) {
			balloon_text += " <img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/unknown.png' /> ";
			balloon_text += "Location: Unknown";
		} else {
			balloon_text += " <img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/country-squared/" + escape(hooked_browser.country_code.toLowerCase()) + ".svg' /> ";
			balloon_text += "Location: " + encode(hooked_browser.city) + ", " + encode(hooked_browser.country);
		}

		balloon_text += "<hr/>";
		balloon_text += "Local Date: " + encode(hooked_browser.date);
		hooked_browser.qtip = balloon_text;

		// set zombie text label for tree node
		var text = "";
		text += "<img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/" + escape(browser_icon) + "' /> ";
		text += "<img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/" + escape(os_icon) + "' /> ";
		text += "<img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/" + escape(hw_icon) + "' /> ";

		if ( !hooked_browser.country || !hooked_browser.country_code || hooked_browser.country == 'Unknown' ) {
			text += "<img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/unknown.png' /> ";
		} else {
			text += "<img width='13px' height='13px' class='zombie-tree-icon' src='<%= @base_path %>/media/images/icons/country-squared/" + escape(hooked_browser.country_code.toLowerCase()) + ".svg' /> ";
		}

		text += encode(hooked_browser.ip);
		hooked_browser.text = text;

		//save a new online HB
		if(online && Ext.pluck(this.online_hooked_browsers_array, 'session').indexOf(hooked_browser.session)==-1) {
			if (<%= BeEF::Core::Configuration.instance.get("beef.extension.admin_ui.play_sound_on_new_zombie") %>) {
				try {
					var sound = new Audio('<%= @base_path %>/media/audio/new_zombie.mp3');
					sound.play();
				} catch(e) {}
			}

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
});
