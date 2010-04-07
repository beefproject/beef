<?php
	// Copyright (c) 2006-2010, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net
?>

<?php
	include ('pw.php');
    require_once("include/filter.inc.php");

	$cache_dir = getcwd() . '/cache';
	$config_file_dir = getcwd() . '/include';
	$config_file = $config_file_dir . '/config.inc.php';

	if ( strcmp( $_GET['passwd'], $passwd) == 0 )
	{
	
		if (!function_exists('file_put_contents')) {
			define('FILE_APPEND', 1);
			function file_put_contents($n, $d, $flag = false) {
				$mode = ($flag == FILE_APPEND || strtoupper($flag) == 'FILE_APPEND') ? 'a' : 'w';
				$f = @fopen($n, $mode);
				if ($f === false) {
					return 0;
				} else {
					if (is_array($d)) $d = implode($d);
					$bytes_written = fwrite($f, $d);
					fclose($f);
					return $bytes_written;
				}
			}
		}

		$beef_domain = "define('BEEF_DOMAIN', 'CONFIG');\n";
		$base_dir = "define('BASE_DIR', 'CONFIG');\n";
		$log_file = "define('LOG_FILE', 'CONFIG');\n";
		$summary_log_file = "define('SUMMARY_LOG_FILE', 'CONFIG');\n";
		
		$config = $_GET["config"];
		if(empty($config) || !valid_url_without_query($config)) {
			echo "ERROR: invalid or no config passed";
			exit(0);
		}

		srand(time());
		$raw_log_file = $cache_dir . '/' . rand() . ".log";
		$raw_summary_log_file = $cache_dir . '/' . rand() . ".log";
	 	$base_dir = preg_replace('/CONFIG/', getcwd() . '/', $base_dir);
	 	$beef_domain = preg_replace('/CONFIG/', $config, $beef_domain);
	 	$log_file = preg_replace('/CONFIG/', $raw_log_file, $log_file);
	 	$summary_log_file = preg_replace('/CONFIG/', $raw_summary_log_file, $summary_log_file);
	 	
		// check permissions on the include and cache
		if((is_writable($config_file) || is_writable($config_file_dir)) && is_writable($cache_dir)) {
			$rtn = file_put_contents($config_file, "<?\n" . $base_dir . $beef_domain . $log_file . $summary_log_file . "?>\n");

		 	// create log file
		 	touch($raw_log_file);
		 	touch($raw_summary_log_file);
		 	
?>
			<h2>BeEF Successfuly Configured</h2>

			<form name="configform">
				<input class="button" type="button" value="Finished" onClick="javascript:location.href='<?php echo $config ?>ui'"/>
			</form>
<?php
		} else {
?>
				<h2>Error</h2>
				Permissions on the <?php printf(getcwd() . '/include' ) ?> directory are incorrect. Running the 
				following command will correct the problem: <br>
				# chown <?php $apacheuser = posix_getpwuid(posix_geteuid()); printf($apacheuser['name'] . " " . getcwd() . '/include' ) ?><br>
				# chown -R <?php printf($apacheuser['name'] . " " . getcwd() . '/cache' ) ?><br>
<?php
			}
	} else { // the password was incorrect
?>
		<h2>Password</h2>
		Incorrect BeEF password, please try again.
<?php
	}
?>
