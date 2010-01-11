// Copyright (c) 2006-2009, Wade Alcorn 
// All Rights Reserved
// wade@bindshell.net - http://www.bindshell.net

// --[ ZOMBIELIST CLASS
var Module = Class.create();
Module.prototype = {
	initialize: function(frequency) {
		this.version   = '0.1',
		this.authors   = 'Wade Alcorn <wade@bindshell.net>',
		this.frequency = frequency,

		this.id = 0;
	},
	heartbeat: function() {
		new Ajax.Updater('module_results_section', 'get_module_details.php?action=get&result_id=' + this.id, {asynchronous:true});
	},
	delete_results: function() {
		new Ajax.Updater('module_results_section', 'get_module_details.php?action=delete&result_id=' + this.id, {asynchronous:true});
		this.heartbeat();
	},
	set_results_id: function(id) {
		this.id = id;
	}
}
