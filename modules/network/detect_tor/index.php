<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	// Module by: Joshua "Jabra" Abraham   <jabra@spl0it.org>
	// http://blog.spl0it.org
	// Thu Jul  9 02:09:25 EDT 2009

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>

	function get_b64_code_tor_enabled() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Detect ToR', get_b64_code_tor_enabled());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_tor_enabled());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Detect TOR</div>
This module will detect if the zombie is using TOR (The Onion Router). <br><br>

<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header"></div>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

