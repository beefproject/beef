function unsafeDetect(){ 
	var unsafe = true;
	
    try{ test = new ActiveXObject("WbemScripting.SWbemLocator"); }         
    catch(ex){unsafe = false;} 
    
    if(unsafe) { 
    	return_result(result_id, "Browser is configured for unsafe active x");
    } else { 
    	return_result(result_id, "Browser is NOT configured for unsafe active x"); 
    }
}

unsafeDetect();
