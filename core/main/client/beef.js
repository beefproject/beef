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
		
		// An array containing functions to be executed by Beef.
		commands: new Array(),
		
		// An array containing all the BeEF JS components.
		components: new Array(),
		
		/**
		 * Adds a function to execute.
		 * @param: {Function} the function to execute.
		 */
		execute: function(fn) {
			this.commands.push(fn);
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
