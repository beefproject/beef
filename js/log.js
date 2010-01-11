// Copyright (c) 2006-2009, Wade Alcorn 
// All Rights Reserved
// wade@bindshell.net - http://www.bindshell.net

function refreshlog() {
	new Ajax.Updater('logdata', 'logcontrol.php?action=refresh', {asynchronous:true});
	update_log_div('logdyn', 'summary');
}

function clearlog() {
	new Ajax.Updater('logdata', 'logcontrol.php?action=clear', {asynchronous:false});
	refreshlog();
}

function update_log_div(div, action) {
	new Ajax.Updater(div, 'logcontrol.php?action=' + action, {asynchronous:true});
}

// --[ LOG CLASS
var Log = Class.create();
Log.prototype = {
	initialize: function(frequency) {
		this.version	= '0.1',
		this.authors	= 'Wade Alcorn <wade@bindshell.net>',
		this.frequency	= frequency
	},
	heartbeat: function() {
		update_log_div('logdyn', 'summary');
	}
}