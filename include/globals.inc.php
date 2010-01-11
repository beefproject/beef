<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net
	
	// if check_install.inc.php works this should exist
	require_once("check_install.inc.php");
	require_once("config.inc.php");

	// files and directories
	// module
	define('MODULE_DIR', BASE_DIR . "modules/");
	
	define('MODULE_STANDARD_SUBDIR', "standard");
	define('MODULE_BROWSER_SUBDIR', "browser");
	define('MODULE_NETWORK_SUBDIR', "network");
	define('MODULE_INTERPROTOCOL_SUBDIR', "interprotocol");

	define('MODULE_STANDARD_DIR',  MODULE_DIR . MODULE_STANDARD_SUBDIR . "/");
	define('MODULE_BROWSER_DIR',  MODULE_DIR . MODULE_BROWSER_SUBDIR . "/");
	define('MODULE_NETWORK_DIR',  MODULE_DIR . MODULE_NETWORK_SUBDIR . "/");
	define('MODULE_INTERPROTOCOL_DIR',  MODULE_DIR . MODULE_INTERPROTOCOL_SUBDIR . "/");

	// temp
	define('TMP_DIR', BASE_DIR . "cache/");
	define('ZOMBIE_TMP_DIR', TMP_DIR . "zombies/");
	define('AUTORUN_TMP_DIR', TMP_DIR . "autorun/");
	define('MODULE_TMP_DIR', TMP_DIR . "modules/");
	define('AUTORUN_TMP_FILENAME', "autorun.js");
	// other
	define('JAVASCRIPT_DIR', BASE_DIR . "js/");
	define('CMD_FILE', TMP_DIR . "cmd.js");
	define('CMD_FILE_BAK', TMP_DIR . "cmd.js.bak");
	define('CMD_RESULT_FILE', TMP_DIR . "cmd.res");
	define('CMD_RESULT_FILE_BAK', TMP_DIR . "cmd.res.bak");
	define('HEARTBEAT_FILE', TMP_DIR . "heartbeat");
	define('HEARTBEAT_FILENAME', "heartbeat");
	define('KEYLOG_FILENAME', "keylog");
	define('SCREEN_FILENAME', "screen");
	define('HTML_FILENAME', "content.html");
	define('COOKIE_FILENAME', "cookie.txt");
	define('LOC_FILENAME', "loc.txt");
	define('RES_LOC_FILENAME', "res_loc");
	define('CLIPBOARD_FILENAME', "clipboard.txt");
	define('CMD_FILENAME', "cmd");
	define('RES_FILENAME', "result");
	define('MODULE_NAME_FILENAME', "name.txt");
	define('BASE64_JAVASCRIPT_FILE', JAVASCRIPT_DIR . "base64.js");
	define('BASE64REPLACE_JAVASCRIPT_FILE', JAVASCRIPT_DIR . "base64replace.js");

	define('HEARTBEAT_TIME', "10000");
	define('HEARTBEAT_FREQUENCY', 5);
	define('SUMMARY_LOG_HEARTBEAT_FREQUENCY', 3);

	// session
	define('SESSION_NAME', "BeEFSession");

	// strings
	define('DNA_STRING', "Data not available");
	define('ERROR_GENERIC', "Error ");

	// zombies (sidebar)
	define('ZOMBIE_NONE', '<li><a href="#">None Connected</a></li>');
	define('ZOMBIE_IMG_ATT', ' width="12" height="12" align="top" border="0"');
	define('ZOMBIE_UA_IMG_TAG', '<img src="../images/AGENT"' . ZOMBIE_IMG_ATT . '>');
	define('ZOMBIE_OS_IMG_TAG', '<img src="../images/OS"' . ZOMBIE_IMG_ATT . '>');
	define('ZOMBIE_IP_TAG', '<div id="zombietext">IPADDRESS</div>');
	define('ZOMBIE_CHANGE_HREF', '<a href="javascript:change_zombie(\'ZOMBIE\')">');
	define('ZOMBIE_NOT_SEL_TAG', '<div id=\'zombies\'>');
	define('ZOMBIE_SEL_TAG', '<div id=\'zombiessel\'>');

	define('ZOMBIE_LINK', ZOMBIE_NOT_SEL_TAG . ZOMBIE_CHANGE_HREF . ZOMBIE_UA_IMG_TAG . 
			ZOMBIE_OS_IMG_TAG . ZOMBIE_IP_TAG . '</a></div>');
	define('ZOMBIE_LINK_SEL', ZOMBIE_SEL_TAG . ZOMBIE_CHANGE_HREF . ZOMBIE_UA_IMG_TAG . 
			ZOMBIE_OS_IMG_TAG . ZOMBIE_IP_TAG . '</a></div>');

	define('MODULE_BUTTON_HTML', '<input class="button" type="button" value="NAME" ' . 
		'onClick="change_module(\'../modules/PATH/\')"/>' . "\n");

	define('MODULE_MENU_ITEM_HTML', '<li><a href="#" onClick="change_module(\'PATH\')">NAME</a></li>');

	// install
	define('INSTALL_WARNING_TEXT', 'ERROR: BeEF may not have been installed correctly.Edit the "' .
		'define(\'BASE_DIR\', "/var/.../htdocs/beef/");' .
		' line of the \'globals.inc.php\' file in the \'include\' dirrctory and point' . 
		' this value at the BeEf install directory.');	
	define('INSTALL_WARNING', '<font size="4" color="red">' . INSTALL_WARNING_TEXT . '</font>');
 
	// agents
	define('AGENT_UNKNOWN_IMG', "unknown.png");
	define('AGENT_FIREFOX_UA_STR', "Firefox");
	define('AGENT_FIREFOX_IMG', "firefox.png");
	define('AGENT_MOZILLA_UA_STR', "Mozilla");
	define('AGENT_MOZILLA_IMG', "mozilla.png");
	define('AGENT_IE_UA_STR', "Internet Explorer");
	define('AGENT_IE_IMG', "msie.png");
	define('AGENT_SAFARI_UA_STR', "Safari");
	define('AGENT_SAFARI_IMG', "safari.png");
	define('AGENT_KONQ_UA_STR', "Konqueror");
	define('AGENT_KONQ_IMG', "konqueror.png");
	define('AGENT_CHROME_UA_STR', "Chrome");
	define('AGENT_CHROME_IMG', "chrome.png");

	// os'es
	define('OS_UNKNOWN_IMG', "unknown.png");
	define('OS_WINDOWS_UA_STR', "Windows");
	define('OS_WINDOWS_IMG', "win.png");
	define('OS_LINUX_UA_STR', "Linux");
	define('OS_LINUX_IMG', "linux.png");
	define('OS_MAC_UA_STR', "Mac");
	define('OS_MAC_IMG', "mac.png");
?>
