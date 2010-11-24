/**
 * @literal object: beef.browser
 *
 * Basic browser functions.
 */
beef.browser = {
	
	/**
	 * Returns the user agent that the browser is claiming to be.
	 * @example: beef.browser.getBrowserReportedName()
	 */
	getBrowserReportedName: function() {						
		return navigator.userAgent;
	},
	
	/**
	 * Returns true if IE6.
	 * @example: beef.browser.isIE6()
	 */
	isIE6: function() {						
		return !window.XMLHttpRequest && !window.globalStorage;
	},
	
	/**
	 * Returns true if IE7.
	 * @example: beef.browser.isIE7()
	 */
	isIE7: function() {						
		return !!window.XMLHttpRequest && !window.chrome && !window.opera && !window.getComputedStyle && !window.globalStorage;
	},
	
	/**
	 * Returns true if IE8.
	 * @example: beef.browser.isIE8()
	 */
	isIE8: function() {						
		return !!document.documentMode && document.documentMode == 8;
	},
	
	/**
	 * Returns true if IE9.
	 * @example: beef.browser.isIE9()
	 */
	isIE9: function() {
		return !!document.documentMode && document.documentMode >= 9;
	},
	
	/**
	 * Returns true if IE.
	 * @example: beef.browser.isIE()
	 */
	isIE: function() {
		return this.isIE6() || this.isIE7() || this.isIE8() || this.isIE9();
	},
	
	/**
	 * Returns true if FF2.
	 * @example: beef.browser.isFF2()
	 */
	isFF2: function() {
		return !!window.globalStorage && !window.postMessage;
	},
	
	/**
	 * Returns true if FF3.
	 * @example: beef.browser.isFF3()
	 */
	isFF3: function() {
		return !!window.globalStorage && !!window.postMessage && !JSON.parse;
	},
	
	/**
	 * Returns true if FF35.
	 * @example: beef.browser.isFF35()
	 */
	isFF35: function() {
		return !!window.globalStorage && !!JSON.parse && !window.FileReader;
	},
	
	/**
	 * Returns true if FF36.
	 * @example: beef.browser.isFF36()
	 */
	isFF36: function() {
		return !!window.globalStorage && !!window.FileReader && !window.multitouchData;
	},

	/**
	 * Returns true if FF4.
	 * @example: beef.browser.isFF4()
	 */
	isFF4: function() {
		return !!window.globalStorage && !!window.history.replaceState;
	},
	
	/**
	 * Returns true if FF.
	 * @example: beef.browser.isFF()
	 */
	isFF: function() {
		return this.isFF2() || this.isFF3() || this.isFF35() || this.isFF36() || this.isFF4();
	},
	
	/**
	 * Returns true if Safari.
	 * @example: beef.browser.isS()
	 */
	isS: function() {
		return !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome;
	},
	
	/**
	 * Returns true if Chrome 5.
	 * @example: beef.browser.isC5()
	 */
	isC5: function() {
		return !!window.chrome && !window.webkitPerformance;
	},
		
	/**
	 * Returns true if Chrome 6.
	 * @example: beef.browser.isC6()
	 */
	isC6: function() {
		return !!window.chrome && !!window.webkitPerformance;
	},

	/**
	 * Returns true if Chrome.
	 * @example: beef.browser.isC()
	 */
	isC: function() {
		return this.isC5() || this.isC6();
	},
		
	/**
	 * Returns true if Opera.
	 * @example: beef.browser.isO()
	 */
	isO: function() {
		return !!window.opera;
	},
		
	/**
	 * Returns the type of browser being used.
	 * @example: beef.browser.type().IE6
	 * @example: beef.browser.type().FF
	 * @example: beef.browser.type().O
	 */
	type: function() {
		
		return {
			C5:		this.isC5(), 	// Chrome 5
			C6:		this.isC6(), 	// Chrome 6
			C:		this.isC(), 	// Chrome any version
			FF2:	this.isFF2(),	// Firefox 2
			FF3:	this.isFF3(),	// Firefox 3
			FF35:	this.isFF35(),	// Firefox 3.5
			FF36:	this.isFF36(),	// Firefox 3.6
			FF4:	this.isFF4(),   // Firefox 4
			FF:		this.isFF(),	// Firefox any version
			IE6:	this.isIE6(),	// Internet Explorer 6
			IE7:	this.isIE7(),	// Internet Explorer 7
			IE8:	this.isIE8(),	// Internet Explorer 8
			IE9:	this.isIE9(),	// Internet Explorer 9
			IE:		this.isIE(),	// Internet Explorer any version
			O:      this.isO(), 	// Opera any version
			S:		this.isS()		// Safari any version
		}
	},
	 
	/**
	 * Returns the type of browser being used.
	 * @return: {String} User agent software and version.
	 *
	 * @example: beef.browser.getBrowserVersion()
	 */
	getBrowserVersion: function() {
				
		if (this.isC5())	{ return '5'  }; 	// Chrome 5
		if (this.isC6())	{ return '6'  }; 	// Chrome 6
		if (this.isFF2())	{ return '2'  };	// Firefox 2
		if (this.isFF3())	{ return '3'  };	// Firefox 3
		if (this.isFF35())	{ return '3.5' };	// Firefox 3.5
		if (this.isFF36())	{ return '3.6' };	// Firefox 3.6
		if (this.isFF4())	{ return '4'  };	// Firefox 4
		if (this.isIE6())	{ return '6'  };	// Internet Explorer 6
		if (this.isIE7())	{ return '7'  };	// Internet Explorer 7
		if (this.isIE8())	{ return '8'  };	// Internet Explorer 8
		if (this.isIE9())	{ return '9'  };	// Internet Explorer 9
		return 'UNKNOWN';						// Unknown UA
	},
	
	/**
	 * Returns the type of user agent by hooked browser.
	 * @return: {String} User agent software.
	 *
	 * @example: beef.browser.getBrowserName()
	 */
	getBrowserName: function() {
				
		if (this.isC())		{ return 'C' }; 	// Chrome any version
		if (this.isFF())	{ return 'FF' };	// Firefox any version
		if (this.isIE())	{ return 'IE' };	// Internet Explorer any version
		if (this.isO())		{ return 'O' };		// Opera any version
		if (this.isS())		{ return 'S' };		// Safari any version
		return 'UNKNOWN';						// Unknown UA
	},
	
	/**
	 * Checks if the zombie has flash installed and enabled.
	 * @return: {Boolean} true or false.
	 *
	 * @example: if(beef.browser.hasFlash()) { ... }
	 */
	hasFlash: function() {
		if (!this.type().IE) {
			return (navigator.mimeTypes && navigator.mimeTypes["application/x-shockwave-flash"]); 
		} else {
			flash_versions = 10;
			flash_installed = false;

			if (window.ActiveXObject) {
				for (x = 2; x <= flash_versions; x++) {
					try {
						Flash = eval("new ActiveXObject('ShockwaveFlash.ShockwaveFlash." + x + "');");
						if (Flash) {
							flash_installed = true;
						}
					}
					catch(e) { }
				}
			};
			return flash_installed;
		}
	},
	
	/**
	 * Checks if the zombie has Java installed and enabled.
	 * @return: {Boolean} true or false.
	 *
	 * @example: if(beef.browser.hasJava()) { ... }
	 */
	hasJava: function() {
		if(!this.type().IE && window.navigator.javaEnabled && window.navigator.javaEnabled()) {
			return true;
		}
		return false;
	},
	
	/**
	 * Checks if the zombie has VBScript enabled.
	 * @return: {Boolean} true or false.
	 *
	 * @example: if(beef.browser.hasVBScript()) { ... }
	 */
	hasVBScript: function() {
		if ((navigator.userAgent.indexOf('MSIE') != -1) && (navigator.userAgent.indexOf('Win') != -1)) {
			return true;
		} else {
			return false;
		}
	},
	
	/**
	 * Returns the list of plugins installed in the browser.
	 */
	getPlugins: function() {
		var results = '';
		if (navigator.plugins && navigator.plugins.length > 0)
		{
			var length = navigator.plugins.length;
			for (var i=0; i < length; i++)
			{
				if (i != 0)
					results += ',';
				results += navigator.plugins[i].name;
			}
		}
		return results;
	},

	/**
	 * Returns zombie screen size and color depth.
	 */	
	getScreenParams: function() {
		return {
			width: window.screen.width, 
			height: window.screen.height,
			colordepth: window.screen.colorDepth
			}
	},

	/**
	 * Returns zombie browser window size.
	 * @from http://www.howtocreate.co.uk/tutorials/javascript/browserwindow
	 */	
	getWindowSize: function() {
		  var myWidth = 0, myHeight = 0;
		  if( typeof( window.innerWidth ) == 'number' ) {
		    // Non-IE
		    myWidth = window.innerWidth;
		    myHeight = window.innerHeight;
		  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
		    // IE 6+ in 'standards compliant mode'
		    myWidth = document.documentElement.clientWidth;
		    myHeight = document.documentElement.clientHeight;
		  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
		    // IE 4 compatible
		    myWidth = document.body.clientWidth;
		    myHeight = document.body.clientHeight;
		  }
		  return {
			  width: myWidth,
			  height: myHeight
		  }
	},
	
	/**
	 * Construct hash from browser details. This function is used to grab the browser details during the hooking process
	 */	
	getDetails: function() {
		var details = new Array();
		
		var browser_name = beef.browser.getBrowserName();
		var browser_version = beef.browser.getBrowserVersion();
		var browser_reported_name = beef.browser.getBrowserReportedName();
		var page_title = document.title;
		var hostname = document.location.hostname;
		var browser_plugins = beef.browser.getPlugins();
		
		if(browser_name) details["BrowserName"] = browser_name;
		if(browser_version) details["BrowserVersion"] = browser_version;
		if(browser_reported_name) details["BrowserReportedName"] = browser_reported_name;
		if(page_title) details["PageTitle"] = page_title;
		if(hostname) details["HostName"] = hostname;
		if(browser_plugins) details["BrowserPlugins"] = browser_plugins;
		
		return details;
	},
	
	/**
	 * Returns array of results, whether or not the target zombie has visited the specified URL
	 */
	hasVisited: function(urls) {
		var results = new Array();
		var iframe = beef.dom.createInvisibleIframe();
		var ifdoc = (iframe.contentDocument) ? iframe.contentDocument : iframe.contentWindow.document;
		ifdoc.open();
		ifdoc.write('<style>a:visited{width:0px !important;}</style>');
		ifdoc.close();
		urls = urls.split("\n");
		var count = 0;
		for (var i in urls)
		{
			var u = urls[i];
			if (u != "" || u != null)
			{
				var success = false;
				var a = ifdoc.createElement('a');
				a.href = u;
				ifdoc.body.appendChild(a);
				var width = null;
				(a.currentStyle) ? width = a.currentStyle['width'] : width = ifdoc.defaultView.getComputedStyle(a, null).getPropertyValue("width"); 
				if (width == '0px') {
					success = true;
				}
				results.push({'url':u, 'visited':success});
				count++;
			}
		}
		beef.dom.removeElement(iframe);
		if (results.length == 0) 
		{
			return false;
		}
		return results;
	}
	
};

beef.regCmp('beef.browser');
