<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
	require_once("../include/common.inc.php");

	// take action based on the detail param
	$action = $_GET["action"];
	switch ($action) {
		case "refresh": 
			echo refresh_log();
			break;
		case "summary": 
			echo refresh_summary_log();
			break;
		case "clear": 
			echo clear();
			break;
		default:  // unknown
			beef_error("unknown detail: $action"); 
	}

	function clear() {
		if(file_exists(LOG_FILE)) {
			unlink(LOG_FILE);
		}
		touch(LOG_FILE);
		if(file_exists(SUMMARY_LOG_FILE)) {
			unlink(SUMMARY_LOG_FILE);
		}
		touch(SUMMARY_LOG_FILE);
	}

	function refresh_log() {	
	 	return get_log();
	}

	function refresh_summary_log() {	
	 	return get_summary_log();
	}

?>
