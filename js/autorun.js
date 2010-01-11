// Copyright (c) 2006-2009, Wade Alcorn 
// All Rights Reserved
// wade@bindshell.net - http://www.bindshell.net

// --[ AUTORUN CLASS
var Autorun = Class.create();
Autorun.prototype = {
	initialize: function() {
		this.version	= '0.1',
		this.authors	= 'Wade Alcorn <wade@bindshell.net>',
		this.enabled	= false,
		this.module	= '',
		this.code	= ''
	},
	// params: string to be displayed in sidebar, base64 encode code
	enable: function(module_name, code) {
		this.code = code;
		var params = 'data='+code;
		new Ajax.Updater('module_status', 'send_cmds.php?action=autorun', {method:'post',parameters:params,asynchronous:false});

		this.enabled	= true;
		this.module	= module_name;
		$('autorun_dyn').innerHTML = this.module + ' Module Enabled';
	},
	disable: function() {
		var params = 'data=disable';
		new Ajax.Updater('module_status', 'send_cmds.php?action=autorun', {method:'post',parameters:params,asynchronous:false});
		this.enabled	= false;
		this.module	= '';
		this.status	= 'Disabled';
		$('autorun_dyn').innerHTML = this.status;
	}
}