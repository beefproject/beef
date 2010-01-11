<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

    require_once("globals.inc.php");

	// --[ BEEF_JS_ERROR
	function beef_js_error($str) {
		echo('<script>alert("' . $str . '")</script>');
	}

	// ---[ GET_B64_FILE
	// returns the contents of a file in base64
    function get_b64_file($file) {
		$raw = file_get_contents($file);
		$result = base64_encode($raw);
        return $result;
    }

	// --[ BEEF_ERROR
	function beef_error() {
		echo ERROR_GENERIC;
		exit;
	}
	
	// --[ GET_LOG
	// returns the log file
	function get_log() {
		$raw = file_get_contents(LOG_FILE);
		$log_data = "";
		
		$log_data = html_encode_all($raw);
	 	$log_data = convert_10_BR($log_data);
	 	
	 	return $log_data;
	}
	
	// --[ GET_LOG
	// returns the log file
	function get_summary_log() {
		$raw = file_get_contents(SUMMARY_LOG_FILE);
		
	 	return $raw;
	}	

	function convert_10_BR($str) {
	 	return preg_replace('/&#10;/', "<br>", $str);
	}

	// --[ HTML_ENCODE_ALL
	// html encodes all characters
	function html_encode_all($str) {
		$rtnstr = "";
	    $strlength = strlen($str);
   	 	for($i = 0; $i < $strlength; $i++){	 		
   	 		$rtnstr .= "&#" . ord($str[$i]) . ";";   	 		
   	 	}		
   	 	
   	 	return $rtnstr;
	}
	
	// --[BEEF_LOG
	// log an entry to the beef log
	function beef_log($summary, $str) {
		// below includes session info - for nat'ed browsers

		$time_stamp = date("d/m/y H:i:s", time());
		$zombie_id = md5(session_id());
		
		// create full log
		$log_entry = "[" . $time_stamp . " " . $_SERVER['REMOTE_ADDR'] . "] " . $str;
		file_put_contents(LOG_FILE, $log_entry . "\n", FILE_APPEND);
		
		//create summary log
		if($summary != "") {
			$time_stamp_link = "<a href=\"javascript:change_zombie('" . md5(session_id()) . "')\">" ;
			$time_stamp_link .= "[" . $time_stamp . " " . $_SERVER['REMOTE_ADDR'] . "]</a>";
			$safe_summary = html_encode_all($summary);
			$safe_summary = convert_10_BR($safe_summary);
			$log_entry = $time_stamp_link . "<br>" . $safe_summary;

			file_start_put_contents(SUMMARY_LOG_FILE, $log_entry . "<br>");
		}
	}
	
	function file_start_put_contents($file, $contents) {
		$temp = tempnam(TMP_DIR, "delme");
		
		touch($temp);
		file_put_contents($temp, $contents, FILE_APPEND);
		$raw = file_get_contents($file);
		file_put_contents($temp, $raw, FILE_APPEND);
		
		unlink($file);
		copy($temp, $file);
		unlink($temp);
		
	}

	if (!function_exists('file_put_contents')) {
		define('FILE_APPEND', 1);
		function file_put_contents($n, $d, $flag = false) {
			$mode = ($flag == FILE_APPEND || strtoupper($flag) == 'FILE_APPEND') ? 'a' : 'w';
			$f = @fopen($n, $mode);
			if ($f === false) {
				return 0;
			} else {
				if (is_array($d)) $d = implode($d);
	       			$bytes_written = fwrite($f, $d);
	       			fclose($f);
				return $bytes_written;
			}
		}
	}

	// --[ MODULE_CODE_AND_RESULT_SETUP
	// this sets up session details for the return of the results and 
	// constructs the code
	function module_code_and_result_setup($cmd_file) {
		// construct file location strings
		$zombie_hook_dir = ZOMBIE_TMP_DIR . session_id();
		
		// create a directory for this zombie if it doens't exist
		if(!file_exists($zombie_hook_dir)) {
			mkdir($zombie_hook_dir);
		}

		$zombie_hook_cmd_file = $zombie_hook_dir . "/" . CMD_FILENAME;
		$zombie_hook_res_file = $zombie_hook_dir . "/" . RES_FILENAME;
		$zombie_hook_res_loc_file = $zombie_hook_dir . "/" . RES_LOC_FILENAME;

		// set the location of the results file in the session
		$result_id = md5(rand());
		$_SESSION[$result_id] = $zombie_hook_res_file;

		// determine where to put the results
		if(file_exists($zombie_hook_res_loc_file)) {
			$res_loc_arr = file($zombie_hook_res_loc_file);
			$_SESSION[$result_id] = MODULE_TMP_DIR . $res_loc_arr[0];
			$_SESSION['append'] = 1;
			unlink($zombie_hook_res_loc_file);
		} else {
			$_SESSION[$result_id] = $zombie_hook_res_file;
			$_SESSION['append'] = 0;
		}

		// get the javascript command file
		$cmd_file_content = file_get_contents($cmd_file);

		// return javascript string to set result_id
		$js_result_id_code ="var result_id = '$result_id';\n";
		
		return $js_result_id_code . $cmd_file_content;
	}

?>
