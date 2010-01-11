<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	session_start();
	require_once("../include/common.inc.php");
	
?>

<div class="entry">
	<p class="title">Raw Log

<div id="zombie_header">
	<a href="#" onclick="refreshlog();">[Refresh Log]</a>
	<a href="#" onclick="clearlog();"> [Clear Log]</a>
</div>

</p>
</div></div>

<div class="log">
<div id="logdata">
<?
	echo get_log();
?>
</div>
</div>
