<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
	require_once("../include/common.inc.php");
	session_start();

	if(!isset($_GET["action"])) beef_error('no action');
	$action = $_GET["action"];

	switch ($action) {
		case "get": // return the results for the module
			if(isset($_SESSION[$_GET["result_id"]])) {
				$file = MODULE_TMP_DIR . $_SESSION[$_GET["result_id"]];
				if(file_exists($file)) {
					$result = file_get_contents($file);
					$result = str_replace(CR, "<br>", $result);
					echo $result;
				} else {
					echo "Results not available";
				}
			}
			break;
		case "delete": // delete the results for the module
			if(isset($_SESSION[$_GET["result_id"]])) {
				$file = MODULE_TMP_DIR . $_SESSION[$_GET["result_id"]];
				if(file_exists($file)) {
					unlink($file);
				}
			}
			break;
	}
?>