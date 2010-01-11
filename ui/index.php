<?php
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	session_start();
	require_once("../include/check_install.inc.php");
	require_once("../include/globals.inc.php");
	require_once("../include/ui_module.inc.php");
	require_once("../include/common.inc.php");
	require_once("../include/browserdetection.inc.php");
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>

<?php
	// set the menu css based upon user agent
	$browser_ua = browser($_SERVER['HTTP_USER_AGENT']);

	$generic_menu_css = '<link rel="stylesheet" type="text/css" href="../css/menu.css">';
	$safari_menu_css = '<link rel="stylesheet" type="text/css" href="../css/safari-menu.css">';
	$ie_menu_css = '<link rel="stylesheet" type="text/css" href="../css/ie-menu.css">';
	
	function generate_css_tags($subdirectory) {
		
		$menu_css = '	<link rel="stylesheet" type="text/css" href="../css/USERAGENT/menu.css">';
		$style_css = '	<link rel="stylesheet" type="text/css" href="../css/USERAGENT/style.css">';
	
		echo preg_replace('/USERAGENT/', $subdirectory, $menu_css);
		echo "\n";
		echo preg_replace('/USERAGENT/', $subdirectory, $style_css);
		echo "\n";
	}
	
	// set css based on the user agent
	if(stristr($browser_ua['name'], AGENT_FIREFOX_UA_STR)) { 
		generate_css_tags('firefox');
	} elseif(stristr($browser_ua['name'], AGENT_IE_UA_STR)) { 
		generate_css_tags('ie');
	} elseif(stristr($browser_ua['name'], AGENT_SAFARI_UA_STR)) { 
		generate_css_tags('safari');
	} else { 
		generate_css_tags('firefox');
	}
	
?>
	<title>Browser Exploitation Framework</title>

	<link rel="icon" href="favicon.ico" type="image/x-icon">
	<script src="../js/prototype.js" type="text/javascript"></script>
	<script src="../js/scriptaculous.js" type="text/javascript"></script>
	<script src="../js/common.js" type="text/javascript"></script>
	<script src="../js/autorun.js" type="text/javascript"></script>
	<script src="../js/zombie.js" type="text/javascript"></script>
	<script src="../js/module.js" type="text/javascript"></script>
	<script src="../js/log.js" type="text/javascript"></script>	
	<script src="../js/msf.js" type="text/javascript"></script>
        
<?php
	// config check
	if(!file_exists(BASE_DIR)) {
		beef_js_error("BASE_DIR needs to be configured. Edit globals.inc.php");
		return;
	}
?>

	<script>
 		var zl  = new ZombieList(<?= HEARTBEAT_FREQUENCY ?>);
 		var ar  = new Autorun();
 		var mod = new Module(<?= HEARTBEAT_FREQUENCY ?>);
 		var log = new Log(<?= SUMMARY_LOG_HEARTBEAT_FREQUENCY ?>);

		var beefPeriodicalExecuter = true;
 		var peZ = new PeriodicalExecuter(function(pe) { if (beefPeriodicalExecuter) { zl.heartbeat();  } else { if (pe) { pe.stop();} } }, zl.frequency);
 		var peM = new PeriodicalExecuter(function(pe) { if (beefPeriodicalExecuter) { mod.heartbeat(); } else { if (pe) { pe.stop();} } }, mod.frequency);
		var peL = new PeriodicalExecuter(function(pe) { if (beefPeriodicalExecuter) { log.heartbeat(); } else { if (pe) { pe.stop();} } }, log.frequency);

		// ---[ START_EXECUTER
		function start_executer() { beefPeriodicalExecuter = true; }

		// ---[ STOP_EXECUTER
		function stop_executer()  { beefPeriodicalExecuter = false; }

		// ---[ BEEF_ERROR
		function beef_error(error_string) {
			new Effect.Shake('beef_icon');
			alert(error_string);
		}

		// ---[ SELECT_ZOMBIE
		function select_zombie(zombie) {
			zl.select_zombie(zombie);
		}

		// ---[ CHANGE_ZOMBIE
		function change_zombie(zombie) {
			zl.set_current_zombie(zombie);
			display_zombie_section();
		}

		// ---[ SEND_CODE
		function do_send(code) {
			zl.send_code(code);
		}

		// ---[ GET_MODULE_RESULTS
		function get_module_results(results_id) {
			new Ajax.Updater('module_results', 'get_module_details.php?result_id=' + results_id, {asynchronous:true});
		}

		// ---[ DISPLAY_GENERAL
		function display_general(page) {
			new Ajax.Updater('general_content', page, {asynchronous:true});
			display_general_section();
		}

		// ---[ CHANGE_MODULE
		function change_module(module) {
			new Ajax.Updater('module_content', module, {asynchronous:true, evalScripts: true});
			display_module_section();
		}

		// ---[ DISPLAY_MODULE_SECTION
		function display_module_section() {
			new Element.hide('zombie_section');
			new Element.hide('general_section');
			new Element.hide('module_results');
			new Element.show('module_section');
		}

		// ---[ DISPLAY_ZOMBIE_SECTION
		function display_zombie_section() {
			new Element.hide('general_section');
			new Element.hide('module_section');
			new Element.show('zombie_section');
		}

		// ---[ DISPLAY_GENERAL_SECTION
		function display_general_section() {
			new Element.hide('zombie_section');
			new Element.hide('module_section');
			new Element.show('general_section');
		}

		// ---[ TOGGLE_SLIDE_DIV
		function toggle_slide_div(div, menu_div) {
			current_menu_html = $(menu_div).innerHTML;

			// check if hidden or shown
			if(current_menu_html.match(/Hide/)) {
				new Effect.SlideUp(div, {duration:1});
				new_menu_html = current_menu_html.replace('Hide', 'Show');
				$(menu_div).innerHTML = new_menu_html;
			} else {
				new Effect.SlideDown(div, {duration:1});
				new_menu_html = current_menu_html.replace('Show', 'Hide');
				$(menu_div).innerHTML = new_menu_html;
			}
		}
		
		// --[ OPEN_WINDOW
		function open_window(url, name) {
			window.open(url, name,"scrollbars,width=800,height=600,toolbar=yes,location=yes,directories=yes,status=yes,menubar=yes,scrollbars=yes,copyhistory=yes");
		}
		
		function unsafe_content_view(zombie) {
			open_window("get_zombie_details.php?zombie=" + zombie + "&detail=unsafe_content", zombie);
		}

		start_executer();
	</script>

</head>
<body>

	<!-- PAGE HEADER -->
	<div id="pageheader">
		<!-- MENU -->
		<div class="menu">
				<ul> <!-- VIEW MENU -->
				<li><a href="#">View</a>
					<ul>
					<li><a href="#" onClick="open_window('../hook/example.php', 'Zombie');">Spawn Zombie Example</a></li>
					<li><a href="#" onClick="display_general('log.php');">Display Raw Log</a></li>
					<li><a href="#" onClick="clearlog();">Clear Main Logs</a></li>
					<li><a href="#" id="zombie_view_menu" onclick="toggle_slide_div('sidebar_zombie','zombie_view_menu');">Hide Sidebar Zombies</a></li>
					<li><a href="#" id="autorun_view_menu" onclick="toggle_slide_div('sidebar_autorun','autorun_view_menu');">Hide Sidebar Autorun</a></li>
					</ul>
				</li>
			</ul>
			
		
			<ul> <!-- ZOMBIES MENU -->
				<li><a href="#">Zombies</a>
					<ul>
					<div id="zombie_menu"><li><a href="#" >Checking for Zombies...</a></li></div>
					</ul>
				</li>
			</ul>
			<ul> <!-- STANDARD MODULES MENU -->
				<li><a href="#">Standard Modules</a>
					<ul>
					<?php echo get_standard_module_menu() ?>
					</ul>
				</li>
			</ul>
			<ul> <!-- BROWSER MENU -->
				<li><a href="#">Browser Modules</a>
					<ul>
					<?php echo get_browser_module_menu() ?>
					</ul>
				</li>
			</ul>
			<ul> <!-- NETWORK MENU -->
				<li><a href="#">Network Modules</a>
					<ul>
					<?php echo get_network_module_menu() ?>
					</ul>
				</li>
			</ul>
			<ul> <!-- OPTIONS MENU -->
				<li><a href="#">Options</a>
					<ul>
					<li><a href="#" onclick="javascript:ar.disable();">Disable Autorun</a></li>
					<li><a href="#" id="start_exec_menu" onclick="start_executer();">Start Server Polling</a></li>
					<li><a href="#" id="stop_exec_menu" onclick="stop_executer();" >Stop Server Polling</a></li>
					</ul>
				</li>
			</ul>
			<ul> <!-- HELP MENU -->
				<li><a href="#">Help</a>
					<ul>
					<li><a href="#" onClick="display_general('help.php')">Local Help</a></li>
					<li><a href="#" onClick="display_general('exampleusage.php')">Example Usage</a></li>
					<li><a href="#" onClick="display_general('thanks.php')">Thanks</a></li>
					<li><a href="#" onClick="display_general('about.php')">About</a></li>
					</ul>
				</li>
			</ul>
		</div>
	</div> 
	<div id="credits"> <!-- CREDITS -->
		<a href=mailto:wade@bindshell.net>Wade Alcorn</a>
		<a href="http://www.bindshell.net/">(http://www.bindshell.net)</a>
	</div>

	<!-- SIDEBAR -->
	<div id="sidebar">
		<!-- BEEF HEADER - LINK AND IMAGE-->
		<div id="header">
			<div id="beefheading">
				<center><a href=http://www.bindshell.net/tools/beef/>Browser Exploitation Framework</a></center>
			</div>
			<h1><div id="beef_icon">
				<img src="../images/beef.gif" onclick="new Effect.Shake('sidebar');"></div> BeEF</h1>
			</div>

		<!-- AUTORUN -->
        <div id="sidebar_autorun">
	        <div id="header" onclick="new Effect.Pulsate('zombiesdyn');">
				<h2>Autorun</h2>
        	</div>
        	<div id="content"> <!-- DYNAMIC AUTORUN SECTION -->
				<div id="autorun_dyn">Disabled</div>
        	</div>
		</div>

		<!-- ZOMBIES -->
        <div id="sidebar_zombie">
	        <div id="header" onclick="new Effect.Pulsate('zombiesdyn');">
				<h2>Zombies</h2>
        	</div>
        	<div id="content"> <!-- DYNAMIC ZOMBIE SECTION -->
				<div id="zombiesdyn">Checking...</div>
        	</div>
		</div>

		</div>
	</div>

	<!-- LOGSIDEBAR -->
	<div id="logsidebar">
		<!-- LOG HEADER -->
		<div id="log_header">
			<div id="header">
				<h2>Log Summary</h2>
			</div>		
				<center>
					<a href="#" onclick="refreshlog();">[Refresh Log]</a>
					<a href="#" onclick="clearlog();"> [Clear Log]</a>
					<a href="#" onclick="display_general('log.php');"> [Display Raw Log]</a>
				</center>
			</div>
			<div id="logdyn">
				 checking... <br>
			</div>
		</div>
	</div>

	<!-- MAIN RIGHT SECTION -->
	<div id="main">
		<div id="page">

			<!-- GENERAL SECTION -->
			<div id=general_section>
				<div id=general_content></div>
			</div>

			<!-- MODULE SECTION -->
			<div id=module_section>
				<div id="module_header"><img src="../images/bones.gif" width="16" heght="16" wionclick="new Effect.Shake('sidebar');"> Module</div>
				<div id=module_content></div>
				<div id=module_status></div>
				<div id=module_results>
					<div id="module_header">Results</div>
					<div id="module_subsection">
						<div id="module_results_section"></div>
						<form name="module_form">
							<!-- DELETE MODULE RESULTS BUTTON -->
							<input class="button" type="button" value="Delete Results" onClick="javascript:mod.delete_results()"/>
						</form>
					</div>
				</div>
			</div>

			<!-- ZOMBIE SECTION -->
			<div id=zombie_section>
			<div id="zombie_icons"></div>

			<!-- ZOMBIE DETAIL SUBSECTION -->
			<div id="zombie_details_header"><div id="zombie_header">
				Details
				<a href="#" onclick="toggle_slide_div('zombie_subsection_details','zombie_details_header');"> [Hide]</a>
			</div></div>
			<div id="zombie_subsection_details">
			<div id="zombie_subsection">
				<div id="zombie_subsection_header">Browser</div>
				<div id="browser_data"></div>
				<div id="zombie_subsection_header">Operating System</div>
				<div id="os_data"></div>
				<div id="zombie_subsection_header">Screen</div>
				<div id="screen_data"></div>
				<div id="zombie_subsection_header">URL</div>
				<div id="loc_data"></div>
				<div id="zombie_subsection_header">Cookie</div>
				<div id="cookie_data"></div>
			</div></div>

			<!-- ZOMBIE PAGE CONTENT SUBSECTION -->
			<div id="zombie_page_content_header"><div id="zombie_header">
				Page Content
				<a href="#" onclick="toggle_slide_div('zombie_subsection_page_content','zombie_page_content_header');"> [Hide]</a>
				<a href="#" onclick="unsafe_content_view(zl.current_zombie);"> [UNSAFE View Content Popup]</a>
			</div></div>
			<div id="zombie_subsection_page_content">
			<div id="zombie_subsection">
				<div id="zombie_subsection_header">Content</div>
				<div id="content_data"></div>
			</div></div>

			<!-- ZOMBIE KEYLOG SUBSECTION -->
			<div id="zombie_keylog_header"><div id="zombie_header">
				Key Logger
				<a href="#" onclick="toggle_slide_div('zombie_subsection_keylog','zombie_keylog_header');"> [Hide]</a>
			</div></div>
			<div id="zombie_subsection_keylog">
			<div id="zombie_subsection">
				<div id="zombie_subsection_header">Keys</div>
				<div id="keylog_data"></div>
			</div></div>

			<!-- ZOMBIE MODULE SUBSECTION -->
			<div id="zombie_module_header"><div id="zombie_header">
				Module Results
				<a href="#" onclick="toggle_slide_div('zombie_subsection_module','zombie_module_header');"> [Hide]</a>
				<a href="#" onclick="zl.clear_current_zombie_results();"> [Clear]</a>
			</div></div>
			<div id="zombie_subsection_module">
			<div id="zombie_subsection">
				<div id="zombie_subsection_header"> </div>
				<div id="zombie_results_data"></div>
			</div></div>

			</div>
			</div>
		</div>
	</div>

	<!-- DEBUG SECTION -->
	<div id="debug" style="position:absolute;top:400px">
		<h4>Server debug messages</h4>
		<textarea id="debugserver" cols="80" rows="5" disabled style="display:none"></textarea>
		<h4>Client debug messages</h4>
		<textarea id="debugclient" cols="80" rows="5" disabled style="display:none"></textarea>
	</div>

	<script>
		new Element.hide('debug');

		var debugserver = 0;
		var debugclient = 0;
		var debugtext   = 0;
		/*
		* simpified wrapper for document.getElementById(element)
		* (other version see prototype.js)
		*/
		function $mid(id) { return(document.getElementById(id)); }

		/*
		* Privat error handling, either a status line (<textarea ..>) or alert()
		*/
		function blert(text) {
			if ($mid('debugserver').style.display != 'block') {
				// alert(text);
				return;
			}
			dbxblert('debugserver',text);
		}
		function dbxblert(target,text) {
			if ($mid(target).style.display != 'block') { return; }
			var statustxt = $mid(target);
			if (statustxt) {
				if (debugtext != '') {
					// print catched errors
					statustxt.value += '\n' + debugtext + '\n**debug**';
					debugtext = '';
				}
				statustxt.value += '\n' + text;
			} else {
				// catch errors before DOM exists
				debugtext += '\n' + text;
			}
		}

		function parse_qs() {
		var opts = new Array();
		opts = document.location.search.split('&');
		if (opts.length>0) {
		opts[0] = opts[0].substr(1);        // strip off leading ?
		}
		// for (var opt in opts) {  // does not work, something wrong with iterator, probably a prototype somewhere
		for (opt=0; opt<opts.length; opt++) {
			if (opts[opt].length <= 0) { continue; }
			switch (opts[opt]) {
			case 'debugserver': $mid('debugserver').style.display = 'block'; new Element.show('debug'); break;
			case 'debugclient': $mid('debugclient').style.display = 'block'; new Element.show('debug'); break;
			default           : alert('**Error: unknown option "'+opts[opt]+'"; ignored'); break;
			}
		}

		}
		parse_qs();
		blert('**debug**');
	</script> 

	<script>
		// display start page
		display_general('about.php');
		toggle_slide_div('zombie_subsection_page_content','zombie_page_content_header');
	</script> 
</body>
</html>
