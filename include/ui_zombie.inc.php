<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("globals.inc.php");
	require_once("browserdetection.inc.php");
	require_once("common.inc.php");

	// ---[ GET_ZOMBIE_OS
	// the output of this function must be escaped
	function get_zombie_os($zombie_id) {
		$heartbeat_file = ZOMBIE_TMP_DIR . $_SESSION[$zombie_id] . "/" . HEARTBEAT_FILENAME;
		$zombie_heartbeat_contents = file($heartbeat_file);
		
		return $zombie_heartbeat_contents[3];
	}

	// ---[ GET_ZOMBIE_BROWSER
	// the output of this function must be escaped
	function get_zombie_browser($zombie_id) {
		$heartbeat_file = ZOMBIE_TMP_DIR . $_SESSION[$zombie_id] . "/" . HEARTBEAT_FILENAME;
		$zombie_heartbeat_contents = file($heartbeat_file);
		
		return trim($zombie_heartbeat_contents[1]) . " " . trim($zombie_heartbeat_contents[2]);
	}

	// ---[ GET_ZOMBIE_METADATA
	function get_zombie_metadata($zombie_id) {		
		$heartbeat_file = ZOMBIE_TMP_DIR . $_SESSION[$zombie_id] . "/" . HEARTBEAT_FILENAME;
		$zombie_details = get_zombie_data($heartbeat_file);

		$zombie_data = trim($zombie_details['ip']);
		$zombie_data .= ',' . $zombie_details['agent_image'];
		$zombie_data .= ',' . $zombie_details['os_image'];

		return $zombie_data;
	}

	// ---[ GET_ZOMBIE_IP
	function get_zombie_ip($zombie_id) {		
		$heartbeat_file = ZOMBIE_TMP_DIR . $_SESSION[$zombie_id] . "/" . HEARTBEAT_FILENAME;
		$zombie_details = get_zombie_data($heartbeat_file);

		return trim($zombie_details['ip']);
	}

	// --[ GET_ZOMBIE_VAR
	function get_zombie_var() {
		if(!isset($_GET["zombie"])) { beef_error('no zombie submitted'); }
		$zombie = $_GET["zombie"];
		if(!isset($_SESSION[$zombie])) { beef_error('zombie not in session');  }

		return $zombie;
	}

	// --[ GET_ZOMBIE_DATAFILE
	function get_zombie_datafile($filename) {
		$zombie = get_zombie_var();

		$zombie_dir = ZOMBIE_TMP_DIR . $_SESSION[$zombie];
		$zombie_file = $zombie_dir . "/" . $filename;

		if(!file_exists($zombie_file)) {
			return DNA_STRING;
		}
		return file_get_contents($zombie_file);
	}

	// --[ DELETE_ZOMBIE_RESULTS
	function delete_zombie_results() {
		$zombie = get_zombie_var();

		$zombie_dir = ZOMBIE_TMP_DIR . $_SESSION[$zombie];
		$zombie_file = $zombie_dir . "/" . RES_FILENAME;

		if(file_exists($zombie_file)) {
			unlink($zombie_file);
		}
	}

	// ---[ GET_ZOMBIE_LIST
	function get_zombie_list() {
		$result = ""; 

		// check installed properly
		if(!file_exists(BASE_DIR)) {
			return INSTALL_WARNING;
		}

		$d = opendir(ZOMBIE_TMP_DIR);
		if(!$d) return false;

		// iterate through directory and parse the heartbeat files
		while($dir_name = readdir($d)) {
			if(!is_dir(ZOMBIE_TMP_DIR . $dir_name)) { continue; } // skip files

			$heartbeat_file = ZOMBIE_TMP_DIR . $dir_name . "/" . HEARTBEAT_FILENAME;
			if(!file_exists($heartbeat_file)) { continue; } // check heartbeat exists

			// check that the heartbeat file is within the age window (HEARTBEAT_TIME)
			$filetime = date("U",filemtime($heartbeat_file));
			if((time() - $filetime) < ((HEARTBEAT_TIME/1000)+1)) {
				// parse zombie details into $zombie_details
				$_SESSION[md5($dir_name)] = $dir_name;

				$zombie_details = get_zombie_data($heartbeat_file);
				$zombie_details['id'] = md5($dir_name); 

				if(!empty($result)) $result .= ",";
				$result .= $zombie_details['id'];

			} else {
				// this means the zombie has been lost
				// leave history/details in directory 
			}
		}

		closedir($d);

		// if no zombies return the default value
		if($result == "") { $result = 'none'; }
                return $result;
	}

	// --[ GET_ZOMBIE_MENU
	function get_zombie_menu() {
		$result = ""; 

		// check installed properly
		if(!file_exists(BASE_DIR)) {
			return INSTALL_WARNING;
		}

		$d = opendir(ZOMBIE_TMP_DIR);
		if(!$d) return false;

		// iterate through directory and parse the heartbeat files
		while($dir_name = readdir($d)) {
			if(!is_dir(ZOMBIE_TMP_DIR . $dir_name)) { continue; } // skip files

			$heartbeat_file = ZOMBIE_TMP_DIR . $dir_name . "/" . HEARTBEAT_FILENAME;
			if(!file_exists($heartbeat_file)) { continue; } // check heartbeat exists

			// check that the heartbeat file is within the age window (HEARTBEAT_TIME)
			$filetime = date("U",filemtime($heartbeat_file));
			if((time() - $filetime) < ((HEARTBEAT_TIME/1000)+1)) {
				// parse zombie details into $zombie_details
				$_SESSION[md5($dir_name)] = $dir_name;

				$zombie_details = get_zombie_data($heartbeat_file);
				$zombie_details['id'] = trim(md5($dir_name)); 

				$result .= '<li><a href="javascript:change_zombie(\'' . $zombie_details['id'] . '\')">' . 
					'<img src="/beef/images/' . $zombie_details['agent_image'] . '" align="top" border="0" height="12" width="12" vspace="2"> ' . 
					'<img src="/beef/images/' . $zombie_details['os_image'] . '" align="top" border="0" height="12" width="12" vspace="2"> ' .
					$zombie_details['ip'] . '</a></li>';
			} else {
				// this means the zombie has been lost
				// leave history/details in directory 
			}
		}

		closedir($d);

		// if no zombies return the default value
		if($result == "") { $result = ZOMBIE_NONE; }
                return $result;
	}

	// ---[ GET_ZOMBIE_DATA
	function get_zombie_data($file){
		$browser_details = file_get_contents($file);

		$zombie_data['ip'] = 		extract_zombie_ip($browser_details);
		$zombie_data['agent_image'] = 	extract_zombie_useragent($browser_details);
		$zombie_data['os_image'] = 	extract_zombie_os($browser_details);

		return $zombie_data;
	}

	// ---[ EXTRACT_ZOMBIE_IP
	function extract_zombie_ip($raw_zombie_data) {
		// get ip address from data
		return substr("$raw_zombie_data",0,strpos($raw_zombie_data,"\n")+strlen("\n"));
	}

	// ---[ EXTRACT_ZOMBIE_USERAGENT
	function extract_zombie_useragent($raw_zombie_data) {
		// find agent type
		if(stristr($raw_zombie_data, AGENT_FIREFOX_UA_STR)) {
			return AGENT_FIREFOX_IMG;
		}
		if(stristr($raw_zombie_data, AGENT_IE_UA_STR)) {
			return AGENT_IE_IMG;
		}
		if(stristr($raw_zombie_data, AGENT_CHROME_UA_STR)) {
			return AGENT_CHROME_IMG;
		}
		if(stristr($raw_zombie_data, AGENT_SAFARI_UA_STR)) {
			return AGENT_SAFARI_IMG;
		}
		if(stristr($raw_zombie_data, AGENT_KONQ_UA_STR)) {
			return AGENT_KONQ_IMG;
		}
		if(stristr($raw_zombie_data, AGENT_MOZILLA_UA_STR)) {
			return AGENT_MOZILLA_IMG;
		}

		return AGENT_UNKNOWN_IMG;
	}

	// ---[ EXTRACT_ZOMBIE_OS
	function extract_zombie_os($raw_zombie_data) {

		// find os type
		if(stristr($raw_zombie_data, OS_WINDOWS_UA_STR)) {
			return OS_WINDOWS_IMG;	
		}
		if(stristr($raw_zombie_data, OS_LINUX_UA_STR)) {
			return OS_LINUX_IMG;	
		}
		if(stristr($raw_zombie_data, OS_MAC_UA_STR)) {
			return OS_MAC_IMG;	
		}

		return OS_UNKNOWN_IMG;
	}

?>
