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
/*
 * The Beef_StatusBar class provides the functionality of the status bar 
 * at the bottom of each tab in the UI
 *
 * @param: {String} unique string for setting the status bar id.
 *
 */

Beef_StatusBar = function(unique_id) {

	var update_fail_wait = 2000; // delay before showing ready status
	var update_sent_wait = 1000; // delay before showing ready status
	
	Beef_StatusBar.superclass.constructor.call(this, {
        id: 'commands-bbar-zombie-' + unique_id,

        // defaults to use when the status is cleared:
        defaultText: 'Ready',
        defaultIconCls: 'x-status-valid',
    
        // values to set initially:
        text: 'Ready',
        iconCls: 'x-status-valid',

		// update status bar to ready		
		update_ready: function(str) {
			var display_str = str || "Ready";
			this.setStatus({
				text: display_str,
				iconCls: 'x-status-valid'
			});
		},

		// update status bar to fail 
		update_fail: function(str){
			var display_str = str || "Error!";
			
			this.setStatus({
				text: display_str,
				iconCls: 'x-status-error',
				clear: {
				    wait: update_fail_wait,
				    anim: true,
				    useDefaults: true
				}
			});
		},

		// update status bar to sending 
		update_sending: function(str) {
			var display_str = str || "Sending...";
			this.showBusy(display_str);
		},

		// update status bar to sent		
		update_sent: function(str) {
			var display_str = str || "Sent";
			this.setStatus({
				text: display_str,
				iconCls: 'x-status-valid',
				clear: {
				    wait: update_sent_wait,
				    anim: true,
				    useDefaults: true
				}
			});
		}

    });

};

Ext.extend(Beef_StatusBar, Ext.ux.StatusBar, {} );

