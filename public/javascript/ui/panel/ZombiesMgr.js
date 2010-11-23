var ZombiesMgr = function(zombies_tree_lists) {
	
	var selectedZombie = null;
	
	var addZombie = function(zombie){
		selectedZombie = zombie;
	}
	
	var delZombie = function(zombie){
		if (selectedZombie.session == zombie.session) {
			selectedZombie = null;
		}
		return null;
	}
	
	var getZombie = function(){
		return selectedZombie;
	}
	
	// this is a helper class to create a zombie object from a JSON hash index
	var zombieFactory = function(index, zombie_array){
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
	
	var updateZombies = function(){
		Ext.Ajax.request({
			url: '/ui/zombies/select/offline/simple.json',
			method: 'POST',
			success: function(response) {
				var offline_zombies = Ext.util.JSON.decode(response.responseText);

				for(tree_type in zombies_tree_lists) {
					zombies = zombies_tree_lists[tree_type];
					zombies.compareAndRemove(offline_zombies, false);
				}
				
				for(tree_type in zombies_tree_lists) {
					zombies = zombies_tree_lists[tree_type];

					for(var i in offline_zombies) {
							var zombie = zombieFactory(i, offline_zombies);
						
							if(tree_type=='requester') {
								//TODO logic for the requester starts here
								zombie['checked'] = true;
							}
							
							zombies.addZombie(zombie, false);
						}
					}
				}
		});
				
		Ext.Ajax.request({
			url: '/ui/zombies/select/online/simple.json',
			method: 'POST',
			success: function(response){
				var online_zombies = Ext.util.JSON.decode(response.responseText);
				
				for(tree_type in zombies_tree_lists) {
					zombies = zombies_tree_lists[tree_type];
					zombies.compareAndRemove(online_zombies, true);
				}
				for(tree_type in zombies_tree_lists) {
					zombies = zombies_tree_lists[tree_type];
					
					for(var i in online_zombies) {	
						var zombie = zombieFactory(i, online_zombies);
						
						if(tree_type=='requester') {
							//TODO logic for the requester starts here
							zombie['checked'] = true;
						}
						
						zombies.addZombie(zombie, true);
					}
				}
				
				for(tree_type in zombies_tree_lists) {
					
					zombies = Ext.getCmp(zombies_tree_lists[tree_type].id);
					
					if(zombies.online_zombies.childNodes.length > 0) {
						//TODO: find a way to destroy folders that are empty
						zombies.online_zombies.expand(true);
					}
					
					if(zombies.offline_zombies.childNodes.length > 0) {
						zombies.offline_zombies.expand(true);
					}
				}
			}
		});
	}
	
	Ext.TaskMgr.start({
		run: updateZombies,
		interval: 8000
	});
}