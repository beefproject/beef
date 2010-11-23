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
        root: new Ext.tree.TreeNode('My Zombies'),
        collapseFirst:false
	});
	
	this.online_zombies = this.root.appendChild(
        new Ext.tree.TreeNode({
            text:'Online Browsers',
            cls:'online-zombies-node',
            expanded:true
        })
    );
	
	this.offline_zombies = this.root.appendChild(
        new Ext.tree.TreeNode({
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
	
	listeners: {
		click: function(node, e) {
			if(!node.leaf) return;
			            
			if(!mainPanel.get(node.attributes.session)) {
				mainPanel.add(new ZombieTab(node.attributes));
			}
			
			mainPanel.activate(node.attributes.session);
		}
	},
	
    selectZombie: function(url){
        this.getNodeById(url).select();
    },

    addZombie : function(attrs, online){
		if(online) {
			var z_id = 'zombie-online-' + attrs.session;
		} else {
			var z_id = 'zombie-offline-' + attrs.session;
		}
		
        var exists = this.getNodeById(z_id);
        
		if(exists){
            return;
        }
		
        Ext.apply(attrs, {
            iconCls: 'feed-icon',
            leaf:true,
            id: z_id
        });
        
		var node = new Ext.tree.TreeNode(attrs);
        var mother_node;
		
		if(online) {
			mother_node = this.online_zombies;
			mother_node = this.addSubFolder(mother_node, node.attributes.domain);
		} else {
			mother_node = this.offline_zombies;
			mother_node = this.addSubFolder(mother_node, node.attributes.domain);
		}
		
		if(online) {
			Ext.apply(attrs, {cls: 'zombie-online'});
			mother_node.appendChild(node);
		} else {
			Ext.apply(attrs, {cls: 'zombie-offline'});
			mother_node.appendChild(node);
		}
		
        return node;
    },

	addSubFolder: function(mother_node, folder, checked) {
		if(mother_node.hasChildNodes()) {
			for(i in mother_node.childNodes) {
				node = mother_node.childNodes[i];
				
				if(typeof node == 'object' && node.attributes.text == folder)
					return node;
			}
		} else {
			sub_folder_node = new Ext.tree.TreeNode({text: folder, 'checked' : checked});
			mother_node.appendChild(sub_folder_node);
			mother_node = sub_folder_node;
		}
		
		return mother_node;
	},
	
	removeAll : function(){
		this.online_zombies.removeAll();
		this.offline_zombies.removeAll();
	},
	
	compareAndRemove : function(zombies, online) {
		for(var i in zombies) {
			if(online) {
				var z = 'zombie-offline-' + zombies[i].session;;
			} else {
				var z = 'zombie-online-' + zombies[i].session;;
			}
			
			var exists = this.getNodeById(z);
			
			if(exists) {
				if(!online) {
					this.online_zombies.removeChild(exists);
				} else {
					this.offline_zombies.removeChild(exists);
				}
			}
		}
	}
});