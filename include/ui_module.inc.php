<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	// ---[ GET_MODULE_BUTTONS_HTML
	// usage: get_module_button_html(button name/lable, browser request path)
	function get_module_button_html($name, $path) {
		$result = MODULE_BUTTON_HTML;

		$result = str_replace("NAME", $name, $result); // button name
		$result = str_replace("PATH", $path, $result); // path to module

		return $result;
	}

	function get_module_menu_item_html($name, $path) {
		$result = MODULE_MENU_ITEM_HTML;

		$result = str_replace("NAME", $name, $result); // button name
		$result = str_replace("PATH", $path, $result); // path to module

		return $result;
	}

	// --[ GET_STANDARD_MODULE_MENU
	function get_standard_module_menu() {
 		$menu_str .= get_module_menu(MODULE_STANDARD_DIR, MODULE_STANDARD_SUBDIR);
		return $menu_str;
	}

	// --[ GET_BROWSER_MODULE_MENU
	function get_browser_module_menu() {
 		$menu_str .= get_module_menu(MODULE_BROWSER_DIR, MODULE_BROWSER_SUBDIR);
		return $menu_str;
	}

	// --[ GET_BROWSER_MODULE_MENU
	function get_network_module_menu() {
 		$menu_str .= get_module_menu(MODULE_NETWORK_DIR, MODULE_NETWORK_SUBDIR);
		return $menu_str;
	}

	// --[ GET_INTERPROTOCOL_MODULE_MENU
	function get_interprotocol_module_menu() {
 		$menu_str .= get_module_menu(MODULE_INTERPROTOCOL_DIR, MODULE_INTERPROTOCOL_SUBDIR);
		return $menu_str;
	}

	// ---[ GET_MODULE_MENU
	function get_module_menu($module_dir, $module_subdir) {
		$result = "";
		$wildcard = $module_dir . '*';

		// iterate through the module directories
		foreach (glob($wildcard) as $dirname) {
			// get module name from file
			$name = file_get_contents($dirname . '/' . MODULE_NAME_FILENAME);
			// create html module buttons
			$result .= get_module_menu_item_html(trim($name), "/beef/modules/". $module_subdir . "/" . basename($dirname));
		}
		return $result;
	}

	// ---[ GET_ALL_MODULE_BUTTONS_HTML
	function get_all_module_menu_items_html() {
		$result = "";
		$wildcard = MODULE_SYMMETRIC_DIR . '*';

		// iterate through the module directories
		foreach (glob($wildcard) as $dirname) {
			// get module name from file
			$name = join("\n", file($dirname . '/' . MODULE_NAME_FILENAME));
			// create html module buttons
			$result .= get_module_menu_item_html(trim($name), "/beef/modules/symmetric/" . basename($dirname));
		}
		return $result;
	}

	// ---[ GET_ALL_MODULE_BUTTONS_HTML
	function get_all_module_buttons_html() {
		$result = "";
		$wildcard = MODULE_SYMMETRIC_DIR . '*';

		// iterate through the module directories
		foreach (glob($wildcard) as $dirname) {
			// get module name from file
			$name = join("<br>", file($dirname . '/' . MODULE_NAME_FILENAME));
			// create html module buttons
			$result .= get_module_button_html(trim($name), "/symmetric/" . basename($dirname));
		}
		return $result;
	}


?>