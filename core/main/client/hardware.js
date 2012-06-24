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

	getName: function() {

		if(this.isNokia()) {

			if (this.ua.indexOf('Maemo Browser') != -1) return 'Maemo';
			if (this.ua.match('(SymbianOS)|(Symbian OS)')) return 'SymbianOS';
			if (this.ua.indexOf('Symbian') != -1) return 'Symbian';

			//return 'Nokia';
		}

		if (this.isWinPhone()) return 'Windows Phone';
		if (this.isBlackBerry()) return 'BlackBerry';
		if (this.isIphone()) return 'iPhone';
		if (this.isIpad()) return 'iPad';
		if (this.isIpod()) return 'iPod';
		if (this.isKindle()) return 'Kindle';

		return 'unknown';
	}
};

beef.regCmp('beef.net.hardware');
