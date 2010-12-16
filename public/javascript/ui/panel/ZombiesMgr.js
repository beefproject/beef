var ZombiesMgr = function(zombies_tree_lists) {
	
	//save the list of trees in the object
	this.zombies_tree_lists = zombies_tree_lists;
	
	// this is a helper class to create a zombie object from a JSON hash index
	this.zombieFactory = function(index, zombie_array){
		text = "<img src='/ui/public/images/icons/"+escape(zombie_array[index]["browser_icon"])+"' style='padding-top:3px;' width='13px' height='13px'/> ";
		text += "<img src='/ui/public/images/icons/"+escape(zombie_array[index]["os_icon"])+"' style='padding-top:3px;' width='13px' height='13px'/> ";
		text += zombie_array[index]["ip"];
		
		var new_zombie = {
			'id' : index,
			'ip' :  zombie_array[index]["ip"],
			'session' : zombie_array[index]["session"],
			'text': text,
			'check' : false,
			'domain' : zombie_array[index]["domain"]
		};
		
		return new_zombie;
	}
	
	/*
	 * Update the hooked browser trees
	 * @param: {Literal Object} an object containing the list of offline and online hooked browsers.
	 * @param: {Literal Object} an object containing the list of rules from the distributed engine.
	 */
	this.updateZombies = function(zombies, rules){
		var offline_zombies = zombies["offline"];
		var online_zombies = zombies["online"];
		
		for(tree_type in this.zombies_tree_lists) {
			hooked_browsers_tree = this.zombies_tree_lists[tree_type];
			
			//we compare and remove the hooked browsers from online and offline branches for each tree.
			hooked_browsers_tree.compareAndRemove(offline_zombies, false);
			hooked_browsers_tree.compareAndRemove(online_zombies, true);
			
			//add an offline browser to the tree
			for(var i in offline_zombies) {
				var offline_hooked_browser = this.zombieFactory(i, offline_zombies);
				hooked_browsers_tree.addZombie(offline_hooked_browser, false);
			}
			
			//add an online browser to the tree
			for(var i in online_zombies) {
				var online_hooked_browser = this.zombieFactory(i, online_zombies);
				hooked_browsers_tree.addZombie(online_hooked_browser, true);
				//TODO: add the rules here
			}
			
			//expand the online hooked browser tree lists
			if(hooked_browsers_tree.online_zombies.childNodes.length > 0) {
				hooked_browsers_tree.online_zombies.expand(true);
			}
			
			//expand the offline hooked browser tree lists
			if(hooked_browsers_tree.offline_zombies.childNodes.length > 0) {
				hooked_browsers_tree.offline_zombies.expand(true);
			}
		}
	}
};