<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>

	get_b64_code_internalhostname = function () {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Detect Hostname', get_b64_code_internalhostname());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_internalhostname());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Detect Hostname</div>
This module will detect the hostname of the selected zombie browsers.<br><br>
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header"></div>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>
