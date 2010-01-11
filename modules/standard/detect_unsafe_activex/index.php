<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>
	function get_b64_code_ua() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Detect Unsafe ActiveX', get_b64_code_ua());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_ua());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Detect Unsafe ActiveX</div>
This module will check if IE has been insecurely configured. It will test if the 
option "Initialize and script ActiveX controls not marked as safe for scripting" 
is enabled.<br /><br />
The setting can be found in:
<pre>
Tools Menu -> Internet Options -> Security -> Custom level -> 
"Initialize and script ActiveX controls not marked as safe for scripting"
</pre>
<div id="module_subsection">
	<form name="myform">
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

