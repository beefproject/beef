function do_main(){	
	
	result = "QuickTime is NOT available in browser";
	
	if (navigator.plugins) {
		for (i=0; i < navigator.plugins.length; i++ ) {
			if (navigator.plugins[i].name.indexOf("QuickTime")>=0){ 
				result = "QuickTime is available in browser";
			}
		}
	}	
	
	if ((navigator.appVersion.indexOf("Mac") > 0) && 
		(navigator.appName.substring(0,9) == "Microsoft") && 
		(parseInt(navigator.appVersion) < 5) ) { 
			result = "QuickTime is available in browser";
		}
}

result = null;
do_main();

return_result(result_id, result);