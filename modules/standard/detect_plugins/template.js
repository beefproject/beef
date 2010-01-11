function do_main(){    

    if (navigator.plugins && navigator.plugins.length > 0) {
        var pluginsArrayLength = navigator.plugins.length;
        
        for (pluginsArrayCounter=0; pluginsArrayCounter < pluginsArrayLength; pluginsArrayCounter++ ) {
            result += navigator.plugins[pluginsArrayCounter].name;
            if(pluginsArrayCounter < pluginsArrayLength-1) {
            	result += String.fromCharCode(10);
            }
        }
    }
}

var result = "";

do_main();

return_result(result_id, result);
