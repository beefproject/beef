/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

var answer = confirm("Do you really want to leave us ??")
if (answer){
	alert("Okay :(")
	send("User chose to leave.");
	window.location = $j(this).attr('href');
}
else{
	alert("Okay enjoy ")
	send("User chose to stay.");
}
