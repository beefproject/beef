//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
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

