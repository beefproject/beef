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