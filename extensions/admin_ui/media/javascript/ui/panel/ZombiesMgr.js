//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

var ZombiesMgr = function(zombies_tree_lists) {

	//save the list of trees in the object
	this.zombies_tree_lists = zombies_tree_lists;

	// this is a helper class to create a zombie object from a JSON hash index
	this.zombieFactory = function(index, zombie_array){

		var ip                 = zombie_array[index]["ip"];
		var session            = zombie_array[index]["session"];
		var browser_name       = zombie_array[index]["name"];
		var browser_version    = zombie_array[index]["version"];
		var os_name            = zombie_array[index]["os"];
		var os_version         = zombie_array[index]["os_version"];
		var hardware           = zombie_array[index]["hardware"];
		var domain             = zombie_array[index]["domain"];
		var port               = zombie_array[index]["port"];
		var city               = zombie_array[index]["city"];
		var country            = zombie_array[index]["country"];
		var country_code       = zombie_array[index]["country_code"];
		var date_stamp         = zombie_array[index]["date_stamp"];

		var new_zombie = {
			'id': index,
			'ip': ip,
			'session': session,
			'check': false,
			'domain': domain,
			'port': port,
			'browser_name': browser_name,
			'browser_version': browser_version,
			'os_name': os_name,
			'os_version': os_version,
			'hw_name': hardware,
			'city': city,
			'country': country,
			'country_code': country_code,
			'date': date_stamp
		};

		return new_zombie;
	}

	/*
	 * Update the hooked browser trees
	 * @param: {Literal Object} an object containing the list of offline and online hooked browsers.
	 */
	this.updateZombies = function(hooked_browsers){
		var offline_hooked_browsers = hooked_browsers["offline"];
		var online_hooked_browsers = hooked_browsers["online"];
		var new_zombie_list = new Array();

		for(tree_type in this.zombies_tree_lists) {
			hooked_browsers_tree = this.zombies_tree_lists[tree_type];

			//we compare and remove the hooked browsers from online and offline branches for each tree.
			hooked_browsers_tree.compareAndRemove(hooked_browsers);

			//add an offline browser to the tree
			for(var i in offline_hooked_browsers) {
				var offline_hooked_browser = this.zombieFactory(i, offline_hooked_browsers);
				hooked_browsers_tree.addZombie(offline_hooked_browser, false, ((tree_type != 'basic') ? true : false));
				new_zombie_list.push(offline_hooked_browser);
			}

			//add an online browser to the tree
			for(var i in online_hooked_browsers) {
				var online_hooked_browser = this.zombieFactory(i, online_hooked_browsers);
				hooked_browsers_tree.addZombie(online_hooked_browser, true, ((tree_type != 'basic') ? true : false));
				new_zombie_list.push(online_hooked_browser);
			}

			//expand the online hooked browser tree lists
			if(hooked_browsers_tree.online_hooked_browsers_treenode.childNodes.length > 0) {
				hooked_browsers_tree.online_hooked_browsers_treenode.expand(true);
			}

			//expand the offline hooked browser tree lists
			if(hooked_browsers_tree.offline_hooked_browsers_treenode.childNodes.length > 0) {
				hooked_browsers_tree.offline_hooked_browsers_treenode.expand(true);
			}

		}
		beefwui.hooked_browsers = new_zombie_list;
	}
};
