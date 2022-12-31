//
// Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/** @namespace beef.os */

beef.os = {

	ua: navigator.userAgent,

	/**
	  * Detect default browser (IE only)
	  * Written by unsticky
	  * http://ha.ckers.org/blog/20070319/detecting-default-browser-in-ie/
	  * @return {string}
	  */
	getDefaultBrowser: function() {
		var result = "Unknown"
		try {
			var mt = document.mimeType;
			if (mt) {
				if (mt == "Safari Document")       result = "Safari";
				if (mt == "Firefox HTML Document") result = "Firefox";
				if (mt == "Chrome HTML Document")  result = "Chrome";
				if (mt == "HTML Document")         result = "Internet Explorer";
				if (mt == "Opera Web Document")    result = "Opera";
			}
		} catch (e) {
			beef.debug("[os] getDefaultBrowser: "+e.message);
		}
		return result;
	},
	
	// the likelihood that we hook Windows 3.11 (which has only Win in the UA string) is zero in 2015
	/**
	 * @return {boolean}
	 */
	isWin311: function() {
		return (this.ua.match('(Win16)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWinNT4: function() {
		return (this.ua.match('(Windows NT 4.0)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWin95: function() {
		return (this.ua.match('(Windows 95)|(Win95)|(Windows_95)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWinCE: function() {
		return (this.ua.match('(Windows CE)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWin98: function() {
		return (this.ua.match('(Windows 98)|(Win98)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWinME: function() {
		return (this.ua.match('(Windows ME)|(Win 9x 4.90)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWin2000: function() {
		return (this.ua.match('(Windows NT 5.0)|(Windows 2000)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWin2000SP1: function() {
		return (this.ua.match('Windows NT 5.01 ')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWinXP: function() {
		return (this.ua.match('(Windows NT 5.1)|(Windows XP)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWinServer2003: function() {
		return (this.ua.match('(Windows NT 5.2)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWinVista: function() {
		return (this.ua.match('(Windows NT 6.0)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWin7: function() {
		return (this.ua.match('(Windows NT 6.1)|(Windows NT 7.0)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWin8: function() {
		return (this.ua.match('(Windows NT 6.2)')) ? true : false;
	},	
	/**
	 * @return {boolean}
	 */
	isWin81: function() {
		return (this.ua.match('(Windows NT 6.3)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWin10: function() {
		return (this.ua.match('Windows NT 10.0')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isOpenBSD: function() {
		return (this.ua.indexOf('OpenBSD') != -1) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isSunOS: function() {
		return (this.ua.indexOf('SunOS') != -1) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isLinux: function() {
		return (this.ua.match('(Linux)|(X11)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isMacintosh: function() {
		return (this.ua.match('(Mac_PowerPC)|(Macintosh)|(MacIntel)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isOsxYosemite: function(){ // TODO
		return (this.ua.match('(OS X 10_10)|(OS X 10.10)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isOsxMavericks: function(){ // TODO
		return (this.ua.match('(OS X 10_9)|(OS X 10.9)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isOsxSnowLeopard: function(){ // TODO
		return (this.ua.match('(OS X 10_8)|(OS X 10.8)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isOsxLeopard: function(){ // TODO
		return (this.ua.match('(OS X 10_7)|(OS X 10.7)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWinPhone: function() {
		return (this.ua.match('(Windows Phone)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isIphone: function() {
		return (this.ua.indexOf('iPhone') != -1) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isIpad: function() {
		return (this.ua.indexOf('iPad') != -1) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isIpod: function() {
		return (this.ua.indexOf('iPod') != -1) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isNokia: function() {
		return (this.ua.match('(Maemo Browser)|(Symbian)|(Nokia)')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isAndroid: function() {
		return (this.ua.match('Android')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isBlackBerry: function() {
		return (this.ua.match('BlackBerry')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWebOS: function() {
		return (this.ua.match('webOS')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isQNX: function() {
		return (this.ua.match('QNX')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isBeOS: function() {
		return (this.ua.match('BeOS')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isAros: function() {
			return (this.ua.match('AROS')) ? true : false;
	},
	/**
	 * @return {boolean}
	 */
	isWindows: function() {
		return (this.ua.match('Windows')) ? true : false;
	},
	/**
	 * @return {string}
	 */
	getName: function() {
		
		if(this.isWindows()){
			return 'Windows';
		}

		if(this.isMacintosh()) {
			return 'OSX';
		}

		//Nokia
		if(this.isNokia()) {
			if (this.ua.indexOf('Maemo Browser') != -1) return 'Maemo';
			if (this.ua.match('(SymbianOS)|(Symbian OS)')) return 'SymbianOS';
			if (this.ua.indexOf('Symbian') != -1) return 'Symbian';
		}

		// BlackBerry
		if(this.isBlackBerry()) return 'BlackBerry OS';

		// Android
		if(this.isAndroid()) return 'Android';

		// SunOS
		if(this.isSunOS()) return 'SunOS';

		//Linux
		if(this.isLinux()) return 'Linux';

		//iPhone
		if (this.isIphone()) return 'iOS';
		//iPad
		if (this.isIpad()) return 'iOS';
		//iPod
		if (this.isIpod()) return 'iOS';
		
		//others
		if(this.isQNX()) return 'QNX';
		if(this.isBeOS()) return 'BeOS';
		if(this.isWebOS()) return 'webOS';
		if(this.isAros()) return 'AROS';
		
		return 'unknown';
	},

  /**
    * Get OS architecture.
    * This may not be the same as the browser arch or CPU arch.
    * ie, 32bit OS on 64bit hardware
    */
  getArch: function() {
    var arch = 'unknown';
    try {
      var arch = platform.os.architecture;
      if (!!arch)
        return arch;
    } catch (e) {}

    return arch;
  },

  /**
    * Get OS family
    */
  getFamily: function() {
    var family = 'unknown';
    try {
      var family = platform.os.family;
      if (!!family)
        return family;
    } catch (e) {}

    return arch;
  },

  /**
    * Get OS name
	* @return {string}
    */
	getVersion: function(){
		//Windows
		if(this.isWindows()) {
			if (this.isWin10())         return '10';
			if (this.isWin81())         return '8.1';
			if (this.isWin8())          return '8';
			if (this.isWin7())          return '7';
			if (this.isWinVista())      return 'Vista';
			if (this.isWinXP())         return 'XP';
			if (this.isWinServer2003()) return 'Server 2003';
			if (this.isWin2000SP1())    return '2000 SP1';
			if (this.isWin2000())       return '2000';
			if (this.isWinME())         return 'Millenium';

			if (this.isWinNT4())        return 'NT 4';
			if (this.isWinCE())         return 'CE';
			if (this.isWin95())         return '95';
			if (this.isWin98())         return '98';
		}

		// OS X
		if(this.isMacintosh()) {
			if (this.isOsxYosemite())        return '10.10';
			if (this.isOsxMavericks())       return '10.9';
			if (this.isOsxSnowLeopard())     return '10.8';
			if (this.isOsxLeopard())         return '10.7';
		}

		// TODO add Android/iOS version detection
	}
};

beef.regCmp('beef.net.os');
