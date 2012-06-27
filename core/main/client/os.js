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
beef.os = {

	ua: navigator.userAgent,
	
	isWin311: function() {
		return (this.ua.indexOf("Win16") != -1) ? true : false;
	},
	
	isWinNT4: function() {
		return (this.ua.match('(Windows NT 4.0)')) ? true : false;
	},
	
	isWin95: function() {
		return (this.ua.match('(Windows 95)|(Win95)|(Windows_95)')) ? true : false;
	},
	
	isWin98: function() {
		return (this.ua.match('(Windows 98)|(Win98)')) ? true : false;
	},
	
	isWinME: function() {
		return (this.ua.indexOf('Windows ME') != -1) ? true : false;
	},
	
	isWin2000: function() {
		return (this.ua.match('(Windows NT 5.0)|(Windows 2000)')) ? true : false;
	},
	
	isWinXP: function() {
		return (this.ua.match('(Windows NT 5.1)|(Windows XP)')) ? true : false;
	},
	
	isWinServer2003: function() {
		return (this.ua.match('(Windows NT 5.2)')) ? true : false;
	},
	
	isWinVista: function() {
		return (this.ua.match('(Windows NT 6.0)')) ? true : false;
	},
	
	isWin7: function() {
		return (this.ua.match('(Windows NT 6.1)|(Windows NT 7.0)')) ? true : false;
	},
	
	isOpenBSD: function() {
		return (this.ua.indexOf('OpenBSD') != -1) ? true : false;
	},
	
	isSunOS: function() {
		return (this.ua.indexOf('SunOS') != -1) ? true : false;
	},
	
	isLinux: function() {
		return (this.ua.match('(Linux)|(X11)')) ? true : false;
	},
	
	isMacintosh: function() {
		return (this.ua.match('(Mac_PowerPC)|(Macintosh)|(MacIntel)')) ? true : false;
	},

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

	isAndroid: function() {
		return (this.ua.match('Android')) ? true : false;
	},

	isBlackBerry: function() {
		return (this.ua.match('BlackBerry')) ? true : false;
	},

	isWebOS: function() {
		return (this.ua.match('webOS')) ? true : false;
	},

	isQNX: function() {
		return (this.ua.match('QNX')) ? true : false;
	},
	
	isBeOS: function() {
		return (this.ua.match('BeOS')) ? true : false;
	},
	
	getName: function() {
		//windows
		if(this.isWin311()) return 'Windows 3.11';
		if(this.isWinNT4()) return 'Windows NT 4';
		if(this.isWin95()) return 'Windows 95';
		if(this.isWin98()) return 'Windows 98';
		if(this.isWinME()) return 'Windows Millenium';
		if(this.isWin2000()) return 'Windows 2000';
		if(this.isWinXP()) return 'Windows XP';
		if(this.isWinServer2003()) return 'Windows Server 2003';
		if(this.isWinVista()) return 'Windows Vista';
		if(this.isWin7()) return 'Windows 7';

		//Nokia
		if(this.isNokia()) {

			if (this.ua.indexOf('Maemo Browser') != -1) return 'Maemo';
			if (this.ua.match('(SymbianOS)|(Symbian OS)')) return 'SymbianOS';
			if (this.ua.indexOf('Symbian') != -1) return 'Symbian';

			//return 'Nokia';
		}

		// BlackBerry
		if(this.isBlackBerry()) return 'BlackBerry OS';

		// Android
		if(this.isAndroid()) return 'Android';

		//linux
		if(this.isLinux()) return 'Linux';
		if(this.isSunOS()) return 'Sun OS';

		//iPhone
		if (this.isIphone()) return 'iOS';
		//iPad
		if (this.isIpad()) return 'iOS';
		//iPod
		if (this.isIpod()) return 'iOS';

		// zune
		//if (this.isZune()) return 'Zune';
		
		//macintosh
		if(this.isMacintosh()) {
			if((typeof navigator.oscpu != 'undefined') && (navigator.oscpu.indexOf('Mac OS')!=-1))
				return navigator.oscpu;
				
			return 'Macintosh';
		}
		
		//others
		if(this.isQNX()) return 'QNX';
		if(this.isBeOS()) return 'BeOS';
		if(this.isWebOS()) return 'webOS';
		
		return 'unknown';
	}
};

beef.regCmp('beef.net.os');
