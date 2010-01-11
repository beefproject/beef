<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<!--

BeEF: this exploit was downloaded from milworm 
http://www.milw0rm.com/exploits/8822

-->

<script>
	function get_b64_code_fd() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('DoS Firefox', get_b64_code_fd());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_fd());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">DoS Firefox (Keygen)</div>
This will DoS firefox and give very limited interaction. A dialog will be displayed repeatedly.<br><br>
<div id="module_subsection">
	<form name="myform">
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

