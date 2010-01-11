function get_content(f){
	 return (f.contentDocument) ? f.contentDocument : f.contentWindow.document;
}

function is_visited(l){
	var dummy = document.getElementById("HIDDEN_FRAME");

	if (!dummy){
		dummy = document.createElement("iframe");
		dummy.style.visibility = "hidden";
		dummy.id = "HIDDEN_FRAME";
		document.body.appendChild(dummy);	

		var dummycontent = get_content(dummy);
		var style  = "<style>a:visited{width:0px};</style>";
		dummycontent.open();
		dummycontent.write(style);
		dummycontent.close();
	} else {
		var dummycontent = get_content(dummy);	
	}

	var dummylink = dummycontent.createElement("a");
	dummylink.href = l;
	dummycontent.body.appendChild(dummylink);

	if (dummylink.currentStyle) {
		visited = dummylink.currentStyle["width"];
	}	else {
		visited = dummycontent.defaultView.getComputedStyle(dummylink, null).getPropertyValue("width");
	}

	return (visited == "0px");
}

function check_list(rawurls) {
	var result = "The browser has visited:";
	var found = false;
	var urllist = rawurls.split(/!/);
	for (var i=0; i < urllist.length; i++) {
		if(is_visited('http://' + urllist[i])) {
			result += String.fromCharCode(10);
			result += 'http://' + urllist[i]; 
			found = true;
		}
	}
	
	if(!found) {
		result += String.fromCharCode(10);
		result += "none found";
	}
	
	return result;
}
	
return_result(result_id, check_list('RAWURLS'));

