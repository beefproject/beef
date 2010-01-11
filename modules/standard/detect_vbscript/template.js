function do_main(){	
	
	if ((navigator.userAgent.indexOf('MSIE') != -1) && 
		(navigator.userAgent.indexOf('Win') != -1)) {
		result = "VBScript is available in browser";
	} else {
		result = "VBScript is NOT available in browser";
	}

}

var result = null;
do_main();

return_result(result_id, result);