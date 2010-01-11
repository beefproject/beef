<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

    require_once("filter.inc.php");
    
	function get_and_filter_exploit() {
		
		$exploit = $_GET["exploit"];
		
		if(strlen($exploit) > 50) {
			return FALSE;
		}
		
		if( !( preg_match("/multi\/browser\/[a-z_]+/", $exploit) ||
				preg_match("/osx\/browser\/[a-z_]+/", $exploit) ||
				preg_match("/windows\/browser\/[a-z_]+/", $exploit)) ) {
			return FALSE;
		}
		
		return $exploit;
	}
  
  	function get_and_filter_payload() {
		
		$payload = $_GET["payload"];
		
		if(strlen($payload) > 50) {
			return FALSE;
		}
		
		if( !preg_match("/[a-z_]+\/[a-z_]+[\/[a-z_]+]{0,1}/", $payload) ) {
			return FALSE;
		}
		
		return $payload;
	}  
	
	function valid_exitfunc($func) {
		if ( ($func == "seh") || ($func == "thread") || ($func == "process") ) {
				return true;
		}
			
		return true;
	}

	function valid_srvhost($ip) {		
		return valid_ip($ip);
	}

	function valid_srvport($port) {
		return valid_port($port);
	}

	function valid_urlpath($path) {
		if( ! preg_match("/^[a-zA-Z0-9\/\.]*$/", $path) ) return FALSE;
        return TRUE;
	}
	
	function get_and_filter_smb_capture_options() {

		$options = array();
		
		// SRVHOST
		if(!$_GET["SRVHOST"]) return FALSE;
		if(!valid_ip($_GET["SRVHOST"])) return FALSE;
		$options["SRVHOST"] = $_GET["SRVHOST"];
		
		// SRVPORT
		if(!$_GET["SRVPORT"]) return FALSE;
		if(!valid_port($_GET["SRVPORT"])) return FALSE;
		$options["SRVPORT"] = $_GET["SRVPORT"];
		
		// URIPATH
		if($_GET["URIPATH"]) {
			if(!valid_urlpath($_GET["URIPATH"])) return FALSE;
			$options["URIPATH"] = $_GET["URIPATH"];
		}
		
		return $options;
	}
	
	function get_and_filter_module_options() {

		$options = array();
		
		// PAYLOAD
		$options["PAYLOAD"] = get_and_filter_payload();
		
		// SRVHOST
		if(!$_GET["SRVHOST"]) return FALSE;
		if(!valid_ip($_GET["SRVHOST"])) return FALSE;
		$options["SRVHOST"] = $_GET["SRVHOST"];
		
		// SRVPORT
		if(!$_GET["SRVPORT"]) return FALSE;
		if(!valid_port($_GET["SRVPORT"])) return FALSE;
		$options["SRVPORT"] = $_GET["SRVPORT"];
		
		// LPORT
		if($_GET["LPORT"]) {
			if(!valid_port($_GET["LPORT"])) return FALSE;
			$options["LPORT"] = $_GET["LPORT"];
		}
		
		// RHOST
		if($_GET["RHOST"]) {
			if(!valid_ip($_GET["RHOST"])) return FALSE;
			$options["RHOST"] = $_GET["RHOST"];
		}
		
		// LHOST
		if($_GET["LHOST"]) {
			if(!valid_ip($_GET["LHOST"])) return FALSE;
			$options["LHOST"] = $_GET["LHOST"];
		}
		
		// URIPATH
		if($_GET["URIPATH"]) {
			if(!valid_urlpath($_GET["URIPATH"])) return FALSE;
			$options["URIPATH"] = $_GET["URIPATH"];
		}
		
		// EXITFUNC
		if($_GET["EXITFUNC"]) {
			if(!valid_exitfunc($_GET["EXITFUNC"])) return FALSE;
			$options["EXITFUNC"] = $_GET["EXITFUNC"];
		}
		
		return $options;
	}
	
?>