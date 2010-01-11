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
	function get_b64_code_vmdetect2() {
		// javascript is loaded from a file - it could be hard coded
		var b64code = '<? echo get_b64_file(JS_FILE); ?>';
		
		return b64code;
	}

	Element.Methods.set_autorun = function() {
		ar.enable('Detect Virtual Machine', get_b64_code_vmdetect2());
	}
	
	Element.Methods.send_now = function() {
		do_send(get_b64_code_vmdetect2());
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<!-- PAGE CONTENT -->
<div id="module_header">Detect Virtual Machine</div>
This module will check if the browser is being run within a VM environment. This 
module will work on any browser that has Java enabled. Currently, it supports 
detection of: VMware, QEMU, VirtualBox and Amazon EC2.<br /><br />

<div id="module_subsection">
	<form name="myform">
		<input class="button" type="button" value=" Set Autorun " onClick="javascript:set_autorun()"/>
		<input class="button" type="button" value=" Send Now " onClick="javascript:send_now()"/>
	</form>
</div>

