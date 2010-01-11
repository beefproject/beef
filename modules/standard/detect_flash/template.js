function do_main(){	
	
	if (navigator.mimeTypes && navigator.mimeTypes["application/x-shockwave-flash"]) {
		result = "Flash is available in browser";
	} else {
		result = "Flash is NOT available in browser";
	}
}

var result = null;
do_main();

return_result(result_id, result);