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
var ZombiesMgr = function(zombies_tree_lists) {
	
	//save the list of trees in the object
	this.zombies_tree_lists = zombies_tree_lists;
	
	// this is a helper class to create a zombie object from a JSON hash index
	this.zombieFactory = function(index, zombie_array){
		text = "<img src='/ui/media/images/icons/"+escape(zombie_array[index]["browser_icon"])+"' style='padding-top:3px;' width='13px' height='13px'/> ";
		text += "<img src='/ui/media/images/icons/"+escape(zombie_array[index]["os_icon"])+"' style='padding-top:3px;' width='13px' height='13px'/> ";
		text += zombie_array[index]["ip"];
		
		var new_zombie = {
			'id' : index,
			'ip' :  zombie_array[index]["ip"],
			'session' : zombie_array[index]["session"],
			'text': text,
			'check' : false,
			'domain' : zombie_array[index]["domain"],
            'port' : zombie_array[index]["port"]
		};
		
		return new_zombie;
	}
	
	/*
	 * Update the hooked browser trees
	 * @param: {Literal Object} an object containing the list of offline and online hooked browsers.
	 * @param: {Literal Object} an object containing the list of rules from the distributed engine.
	 */
	this.updateZombies = function(zombies, rules){
		var offline_hooked_browsers = zombies["offline"];
		var online_hooked_browsers = zombies["online"];
		
		for(tree_type in this.zombies_tree_lists) {
			hooked_browsers_tree = this.zombies_tree_lists[tree_type];
			
			//we compare and remove the hooked browsers from online and offline branches for each tree.
			hooked_browsers_tree.compareAndRemove(zombies);
			
			//add an offline browser to the tree
			for(var i in offline_hooked_browsers) {
				var offline_hooked_browser = this.zombieFactory(i, offline_hooked_browsers);
				hooked_browsers_tree.addZombie(offline_hooked_browser, false, ((tree_type != 'basic') ? true : false));
			}
			
			//add an online browser to the tree
			for(var i in online_hooked_browsers) {
				var online_hooked_browser = this.zombieFactory(i, online_hooked_browsers);
				hooked_browsers_tree.addZombie(online_hooked_browser, true, ((tree_type != 'basic') ? true : false));
			}
			
			//apply the rules to the tree
			hooked_browsers_tree.applyRules(rules);
			
			//expand the online hooked browser tree lists
			if(hooked_browsers_tree.online_hooked_browsers_treenode.childNodes.length > 0) {
				hooked_browsers_tree.online_hooked_browsers_treenode.expand(true);
			}
			
			//expand the offline hooked browser tree lists
			if(hooked_browsers_tree.offline_hooked_browsers_treenode.childNodes.length > 0) {
				hooked_browsers_tree.offline_hooked_browsers_treenode.expand(true);
			}

		}
	}
};
