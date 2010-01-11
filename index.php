<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>

<?php

	require_once("include/browserdetection.inc.php");
	require_once("include/filter.inc.php");

	// set the menu css based upon user agent
	$browser_ua = browser($_SERVER['HTTP_USER_AGENT']);

	function generate_css_tags($subdirectory) {
		
		$menu_css = '	<link rel="stylesheet" type="text/css" href="css/USERAGENT/menu.css">';
		$style_css = '	<link rel="stylesheet" type="text/css" href="css/USERAGENT/style.css">';
	
		echo preg_replace('/USERAGENT/', $subdirectory, $menu_css);
		echo preg_replace('/USERAGENT/', $subdirectory, $style_css);
	}
	
	// set css based on the user agent
	if(stristr($browser_ua['name'], "Firefox")) { 
		generate_css_tags('firefox');
	} elseif(stristr($browser_ua['name'], "Internet Explorer")) { 
		generate_css_tags('ie');
	} elseif(stristr($browser_ua['name'], "Safari")) { 
		generate_css_tags('safari');
	} else { 
		generate_css_tags('firefox');
	}
	
	$url = "http://" . $_SERVER['SERVER_NAME']. $_SERVER['REQUEST_URI'];
	if(! valid_url_without_query($url)) $url = "";
	
?>
	
	<title>Browser Exploit Framework</title>

	<link rel="icon" href="favicon.ico" type="image/x-icon">
	<script src="js/prototype.js" type="text/javascript"></script>
	<script src="js/scriptaculous.js" type="text/javascript"></script>
	<script src="js/common.js" type="text/javascript"></script>

	<script>

		// ---[ BEEF_ERROR
		function beef_error(error_string) {
			new Effect.Shake('beef_icon');
			alert(error_string);
		}

		// ---[ SUBMIT_CONFIG
		function submit_config(config, passwd) {
			new Ajax.Updater('config_results', 'submit_config.php?config=' + config + '&passwd=' + passwd, {asynchronous:true});
		}

	</script>

</head>
<body>

	<!-- SIDEBAR -->
	<div id="sidebar">
		<!-- BEEF HEADER - LINK AND IMAGE-->
		<div id="header">
			<center><a href=http://www.bindshell.net/tools/beef/>Browser Exploitation Framework</a></center>
			<h1><div id="beef_icon"><img src="images/beef.gif" onclick="new Effect.Shake('sidebar');"></div> BeEF</h1>
		</div>

		<!-- Security -->
        	<div id="sidebar_autorun">
	        	<div id="header" onclick="new Effect.Pulsate('zombiesdyn');">
				<h2>Security</h2>
        		</div>
        		<div id="content">
				<!-- DYNAMIC ZOMBIE SECTION -->
				<div id="autorun_dyn">BeEF has no security by design <br><br></div>
				<div id="autorun_dyn">Default password is <b>BeEFConfigPass</b> <br><br></div>
				<div id="autorun_dyn">Edit 'pw.php' in BeEF root to alter the password</div>
        		</div>
		</div>

		<!-- INSTALL -->
        	<div id="sidebar_autorun">
	        	<div id="header" onclick="new Effect.Pulsate('zombiesdyn');">
				<!--<h2>Installation</h2>-->
        		</div>
        		<div id="content">
				<!-- DYNAMIC ZOMBIE SECTION -->
				<!-- <div id="autorun_dyn">BeEF has not been installed</div> -->
        		</div>
		</div>

	</div>

	<!-- MAIN RIGHT SECTION -->
	<div id="main">
		<div id="page">
			<div id="module_header">BeEF Configuration</div>
				<br>
				<div id="module_subsection">
        				<form name="configform">
                				<div id="module_subsection_header">Connection (IP Address or URL)</div>
						This is the location that the zombies will connect to (do not include the hook directory). This must match the 'ServerName' value in your http.conf for the modules to work.
                				<input type="text" name="url" value="<? echo $url; ?>" autocomplete="off"/>
                				BeEF configuration password
                				<input type="password" name="passwd" value="BeEFConfigPass" autocomplete="off"/>
                				<input class="button" type="button" value="Apply Config" onClick="javascript:submit_config(configform.url.value, configform.passwd.value)"/>
						<br>Clicking 'Apply Configuration' will remove/replace these configuration files
        				</form>
				</div>
				<div id='config_results'></div>
			</div>

		</div>
	</div>

</body>
</html>
