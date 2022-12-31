//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * BeEF JS Library <%= @beef_version %>
 * Register the BeEF JS on the window object.
 */

$j = jQuery.noConflict();

if(typeof beef === 'undefined' && typeof window.beef === 'undefined') {

    /**
     * Register the BeEF JS on the window object.
     * @namespace {Object} BeefJS 
     * @property {string} version BeEf Version
     * @property {boolean} pageIsLoaded This gets set to true during window.onload(). It's a useful hack when messing with document.write().
     * @property {array} onpopstate An array containing functions to be executed by the window.onpopstate() method.
     * @property {array} onclose An array containing functions to be executed by the window.onclose() method.
     * @property {array} commands An array containing functions to be executed by Beef.
     * @property {array} components An array containing all the BeEF JS components.
     */

    var BeefJS = {
        
        version: '<%= @beef_version %>',
        pageIsLoaded: false,
        onpopstate: new Array(),
        onclose: new Array(),
        commands: new Array(),
        components: new Array(),

        /**
         * Adds a function to display debug messages (wraps console.log())
         * @param: {string} the debug string to return
         */
        debug: function(msg) {
            isDebug = '<%= @client_debug %>'
            if (typeof console == "object" && typeof console.log == "function" && isDebug === 'true') {
                var currentdate = new Date();
                var pad = function(n){return ("0" + n).slice(-2);}
                var datetime = currentdate.getFullYear() + "-"
                + pad(currentdate.getMonth()+1)  + "-"
                + pad(currentdate.getDate()) + " "
                + pad(currentdate.getHours()) + ":"
                + pad(currentdate.getMinutes()) + ":"
                + pad(currentdate.getSeconds());
                console.log('['+datetime+'] '+msg);
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
