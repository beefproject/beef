var ZombiesMgr = function(zombies) {
	
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
		text = zombie_array[index]["ip"]
		text = "<img src='/ui/public/images/icons/"+escape(zombie_array[index]["os_icon"])+"' style='padding-top:3px;' width='13px' height='13px'/> "+text
		
		var new_zombie = {
			'id' : index,
			'ip' :  zombie_array[index]["ip"],
			'session' : zombie_array[index]["session"],
			'text': text,
			'icon': '/ui/public/images/icons/'+escape(zombie_array[index]["browser_icon"]),
			'domain' : zombie_array[index]["domain"]
		};
		
		return new_zombie;
	}
	
	var updateZombies = function(){
		Ext.Ajax.request({
			url: '/ui/zombies/select/offline/simple.json',
			success: function(response) {
				var offline_zombies = Ext.util.JSON.decode(response.responseText);

				zombies.compareAndRemove(offline_zombies, false);
				
				for(var i in offline_zombies) {

					var zombie = zombieFactory(i, offline_zombies);
					
					zombies.addZombie(zombie, false);
				}
			}
		});
				
		Ext.Ajax.request({
			url: '/ui/zombies/select/online/simple.json',
			success: function(response){
				var online_zombies = Ext.util.JSON.decode(response.responseText);
				
				zombies.compareAndRemove(online_zombies, true);
				for(var i in online_zombies) {
					
					var zombie = zombieFactory(i, online_zombies);

					zombies.addZombie(zombie, true);
				}
				
				if(zombies.online_zombies.childNodes.length > 0) {
					zombies.online_zombies.expand(true);
				}

				if(zombies.offline_zombies.childNodes.length > 0) {
					zombies.offline_zombies.expand(true);
				}
			}
		});
	}
	
	Ext.TaskMgr.start({
		run: updateZombies,
		interval: 8000
	});
}