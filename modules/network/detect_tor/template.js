function using_tor() {
	result = "Tor is being used";
}
function not_using_tor() {
	result = "Tor is NOT being used";
}
function do_main() {
	var img = new Image();

    img.onload = using_tor();
	img.onerror = not_using_tor();
	img.setAttribute("width", "0");
    img.setAttribute("height", "0");
	img.setAttribute("style", "visibility:hidden;");
	img.src = 'http://dige6xxwpt2knqbv.onion/wink.gif';

	document.body.appendChild(img);

    return "Request Sent";
}

var result = null;
do_main();

return_result(result_id, result);
