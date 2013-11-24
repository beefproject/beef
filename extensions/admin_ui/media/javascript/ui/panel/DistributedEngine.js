//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*
 * RULES TYPE
 * - DOMAIN : DOMAIN www.zzz.com
 * - EXTERNAL : EXTERNAL 123.456.789.123
 * - INTERNAL : INTERNAL 10.0.0.3
 */
DistributedEngine = function() {
	//defines the constant code to match with the backend ruby
	this.CONSTANTS = {
		'requester' : 1,
		'portscanner' : 2
	};
	
	/*
	 * Returns true of the hooked browser matches one of the rules and should be checked.
	 * @param: {Literal Object} the browser object.
	 * @param: {Literal Object} the rule set object.
	 * @return: {Boolean} true if matches, false if not.
	 */
	this.HookedBrowserMatchesRules = function(hooked_browser, rules) {
		
	};
	
	/*
	 * Disable an existing rule in the framework. That function is called when the user
	 * unchecks a hooked browser.
	 * @param: {Integer} the id of the rule.
	 */
	this.DisableRule = function(rule_id) {
		
	};
	
	/*
	 * Creates and sends a new rule to the backend.
	 */
	this.CreateNewRule = function() {
		
	};
};