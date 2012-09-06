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
