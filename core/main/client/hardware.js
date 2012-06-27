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
beef.hardware = {

	ua: navigator.userAgent,
	
	isWinPhone: function() {
		return (this.ua.match('(Windows Phone)')) ? true : false;
	},
	
	isIphone: function() {
		return (this.ua.indexOf('iPhone') != -1) ? true : false;
	},

	isIpad: function() {
		return (this.ua.indexOf('iPad') != -1) ? true : false;
	},

	isIpod: function() {
		return (this.ua.indexOf('iPod') != -1) ? true : false;
	},

	isNokia: function() {
		return (this.ua.match('(Maemo Browser)|(Symbian)|(Nokia)')) ? true : false;
	},

	isBlackBerry: function() {
		return (this.ua.match('BlackBerry')) ? true : false;
	},

	isZune: function() {
		return (this.ua.match('ZuneWP7')) ? true : false;
	},

	isKindle: function() {
		return (this.ua.match('Kindle')) ? true : false;
	},

	isHtc: function() {
		return (this.ua.match('HTC')) ? true : false;
	},

	isEricsson: function() {
		return (this.ua.match('Ericsson')) ? true : false;
	},

	isNokia: function() {
		return (this.ua.match('Nokia')) ? true : false;
	},

	isMotorola: function() {
		return (this.ua.match('Motorola')) ? true : false;
	},

	isGoogle: function() {
		return (this.ua.match('Nexus One')) ? true : false;
	},

	getName: function() {

		if (this.isNokia()) return 'Nokia';
		if (this.isWinPhone()) return 'Windows Phone';
		if (this.isBlackBerry()) return 'BlackBerry';
		if (this.isIphone()) return 'iPhone';
		if (this.isIpad()) return 'iPad';
		if (this.isIpod()) return 'iPod';
		if (this.isKindle()) return 'Kindle';
		if (this.isHtc()) return 'HTC';
		if (this.isMotorola()) return 'Motorola';
		if (this.isZune()) return 'Zune';
		if (this.isGoogle()) return 'Google';
		if (this.isEricsson()) return 'Ericsson';

		return 'Unknown';
	}
};

beef.regCmp('beef.net.hardware');
