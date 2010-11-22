beef.os = {

	ua: navigator.userAgent,
	
	isWin311: function() {
		return (this.ua.indexOf("Win16")) ? true : false;
	},
	
	isWinXP: function() {
		return this.ua.match('(Windows NT 5.1)|(Windows XP)');
	}
	
};

alert(beef.os.isWinXP());

beef.regCmp('beef.net.os');