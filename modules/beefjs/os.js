beef.os = {

	ua: navigator.userAgent,
	
	isWin311: function() {
		return (this.ua.indexOf("Win16") != -1) ? true : false;
	},
	
	isWinNT4: function() {
		return (this.ua.match('(Windows NT 4.0)|(WinNT4.0)|(WinNT)|(Windows NT)') && !this.isWinXP()) ? true : false;
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
	
	isQNX: function() {
		return (this.ua.indexOf('QNX')) ? true : false;
	},
	
	isBeOS: function() {
		return (this.ua.indexOf('BeOS')) ? true : false;
	},
	
	getName: function() {
		//windows
		if(this.isWin311()) return 'Windows 3.11';
		if(this.isWinNT4()) return 'Windows NT 4';
		if(this.isWin95()) return 'Windows 95';
		if(this.isWin95()) return 'Windows 98';
		if(this.isWin98()) return 'Windows 98';
		if(this.isWinME()) return 'Windows Millenium';
		if(this.isWin2000()) return 'Windows 2000';
		if(this.isWinXP()) return 'Windows XP';
		if(this.isWinVista()) return 'Windows Vista';
		if(this.isWin7()) return 'Windows 7';
		
		//linux
		if(this.isLinux()) return 'Linux';
		if(this.isSunOS()) return 'Sun OS';
		
		//macintosh
		if(this.isMacintosh()) {
			if((typeof navigator.oscpu != 'undefined') && (navigator.oscpu.indexOf('Mac OS')!=-1))
				return navigator.oscpu;
				
			return 'Macintosh';
		}
		
		//others
		if(this.isQNX()) return 'QNX';
		if(this.isBeOS()) return 'BeOS';
		
		return 'unknown';
	}
};

beef.regCmp('beef.net.os');