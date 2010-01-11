<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>

	get_b64_code_status = function () {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// replace sections of the code with user input
		b64code = b64replace(b64code, "STATUSBARSTRING", document.myform.status_str.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Rewrite Status Bar', get_b64_code_status());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_status());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Rewrite Status Bar</div>
This module will rewrite the status bar of the selected zombies.<br><br>

<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">String</div>
		<input type="text" width="90%" name="status_str" value="BeEF - http://www.bindshell.net/tools/beef"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>
