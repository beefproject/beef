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
        
		if(online) {
			Ext.apply(attrs, {cls: 'zombie-online'});
			this.online_zombies.appendChild(node);
		} else {
			Ext.apply(attrs, {cls: 'zombie-offline'});
			this.offline_zombies.appendChild(node);
		}
		
        return node;
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