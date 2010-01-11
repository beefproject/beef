<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
	require_once("../include/common.inc.php");

	session_name(SESSION_NAME);
	session_start();

	// location of auto run file
	$autorun_file = AUTORUN_TMP_DIR . AUTORUN_TMP_FILENAME;

	// that auto run been set
	if(!file_exists($autorun_file)) { return ""; }

	// set up the return_id, session and get the code
	$code = module_code_and_result_setup($autorun_file);
	
	echo $code;
?>
