<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>

	get_b64_code_alert = function () {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// replace sections of the code with user input
		b64code = b64replace(b64code, "ALERTSTRING", document.myform.alert_str.value);
		b64code = b64replace(b64code, "RTN", "Alert Clicked");
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Alert Dialog', get_b64_code_alert());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_alert());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Alert Dialog</div>
This module will display an alert dialog in the selected zombie browsers.<br><br>
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">String</div>
		<input type="text" width="90%" name="alert_str" value="BeEF Alert Dialog"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>
