function do_main() {
    var ret;
    
    if(navigator.userAgent.match(REGEXP)) {
   
	    try {
	        ret = CMD;
	    } catch(e) {
	        for(var n in e)
	            ret+= n + " " + e[n] + "CR";
	    }
    }
    
    return ret;
}

do_main();
