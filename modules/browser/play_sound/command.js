//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {	
  var url = "<%== @sound_file_uri %>";
  try {	
    var sound = new Audio(url);
    sound.play();
    beef.debug("[Play Sound] Played sound successfully: " + url);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Sound Played", beef.are.status_success());
  } catch (e) {
    beef.debug("[Play Sound] HTML5 audio unsupported. Could not play: " + url);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "fail=audio not supported", beef.are.status_error());
  }
});
