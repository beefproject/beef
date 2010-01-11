<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

		function valid_ip($ip) {		
		return filter_var($ip, FILTER_VALIDATE_IP);
	}

	function valid_port($port) {
		$int_options = array("options"=>array("min_range"=>0, "max_range"=>65535));
		return filter_var($port, FILTER_VALIDATE_INT, $int_options);
	}
	
	function valid_url($url) {
		if( preg_match("/\.\./", $url) ) return FALSE;
		if( ! preg_match("/^[a-zA-Z0-9\._:\/]*$/", $url) ) return FALSE;
		return filter_var($url, FILTER_VALIDATE_URL, FILTER_FLAG_SCHEME_REQUIRED);
	}
	
	function valid_url_without_query($url) {
		if(filter_var($url, FILTER_FLAG_QUERY_REQUIRED)) return FALSE;
		return valid_url($url);
	}	

?>