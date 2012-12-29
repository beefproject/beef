//
// Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
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
