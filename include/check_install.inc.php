<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("filter.inc.php");
	
	if(!file_exists('../include/config.inc.php') 
		&& !file_exists('../../include/config.inc.php') 
		&& !file_exists('../../../include/config.inc.php')) {
		
		$install_url =  "http://" . $_SERVER['SERVER_NAME'] . $_SERVER['REQUEST_URI']; 
		
		if(valid_url_without_query($install_url)) {
			echo "<script>location.href = '" . $install_url . "..'</script>";
			echo '<li><a href="..">Configure BeEF</a></li>';
		} else {
			echo 'Install and configure BeEF first';
		}
		
		exit(0);
	}
		
?>