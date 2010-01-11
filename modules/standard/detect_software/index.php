<?
	// Copyright (c) 2006-2009, Wade Alcorn 
    // All Rights Reserved
    // wade@bindshell.net - http://www.bindshell.net
    //
    // Module by:   Joshua "Jabra" Abraham 
    // jabra@spl0it.org
    // http://blog.spl0it.org
    // 
    // This modules uses the process outlined by RSnake at http://ha.ckers.org/blog/20090809/smbenum/
    //
    
    require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');
?>

<script>
	function get_b64_code() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Detect Software', get_b64_code());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Detect Software</div>
This module detects the software that is installed on the client. It uses a process of SMB enumeration.<br><br>

This module only works in Internet Explorer.<br><br>
<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header"></div>
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

