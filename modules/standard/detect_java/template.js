function do_main(){	
	
	// https://developer.mozilla.org/en/DOM/window.navigator.javaEnabled
	// bug in XP SP2 
	if( window.navigator.javaEnabled() ) {
		result = "Java is available in browser";
	} else {
		result = "Java is NOT available in browser";
	}

}

var result = null;

do_main();

return_result(result_id, result);