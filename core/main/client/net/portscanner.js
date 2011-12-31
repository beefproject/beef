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
/*!
 * @literal object: beef.net.portscanner
 * 
 * Provides port scanning functions for the zombie. A mod of pdp's scanner
 * 
 * Version: '0.1',
 * author: 'Petko Petkov',
 * homepage: 'http://www.gnucitizen.org'
 */

beef.net.portscanner = {

		scanPort: function(callback, target, port, timeout) 
		{
			var timeout = (timeout == null)?100:timeout;
			var img = new Image();

			img.onerror = function () {
				if (!img) return;
				img = undefined;
				callback(target, port, 'open');
			};

			img.onload  = img.onerror;
			
			img.src = 'http://' + target + ':' + port;

			setTimeout(function () {
				if (!img) return;
				img = undefined;
				callback(target, port, 'closed');
			}, timeout);

		},

		scanTarget: function(callback, target, ports_str, timeout)
		{
			var ports = ports_str.split(",");

			for (index = 0; index < ports.length; index++) {
				this.scanPort(callback, target, ports[index], timeout);
			};

		}
};

beef.regCmp('beef.net.portscanner');

