//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * BeEF JS Library <%= @beef_version %>
 * Register the BeEF JS on the window object.
 */

$j = jQuery.noConflict();

if(typeof beef === 'undefined' && typeof window.beef === 'undefined') {
	
	var BeefJS = {
		
		version: '<%= @beef_version %>',
		
		// This get set to true during window.onload(). It's a useful hack when messing with document.write().
		pageIsLoaded: false,
		
		// An array containing functions to be executed by the window.onpopstate() method.
		onpopstate: new Array(),
		
		// An array containing functions to be executed by the window.onclose() method.
		onclose: new Array(),
		
		// An array containing functions to be executed by Beef.
		commands: new Array(),
		
		// An array containing all the BeEF JS components.
		components: new Array(),

                /**
                 * Adds a function to display debug messages (wraps console.log())
                 * @param: {string} the debug string to return
                 */
                debug: function(msg) {
                    if (!<%= @client_debug %>) return;
                    if (typeof console == "object" && typeof console.log == "function") {
                        console.log(msg);
                    } else {
                        // TODO: maybe add a callback to BeEF server for debugging purposes
                        //window.alert(msg);
                    }
                },

		/**
		 * Adds a function to execute.
		 * @param: {Function} the function to execute.
		 */
		execute: function(fn) {
            if ( typeof  beef.websocket == "undefined"){
                 this.commands.push(fn);
            }else{
                fn();
            }
        },



		/**
		 * Registers a component in BeEF JS.
		 * @params: {String} the component.
		 *
		 * Components are very important to register so the framework does not
		 * send them back over and over again.
		 */
		regCmp: function(component) {
			this.components.push(component);
		}
	
    };
	
	window.beef = BeefJS;
}
