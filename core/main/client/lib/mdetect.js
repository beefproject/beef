/* *******************************************
// Copyright 2010-2015, Anthony Hand
//
// BETA NOTICE
// Previous versions of the JavaScript code for MobileESP were 'regular' 
// JavaScript. The strength of it was that it was really easy to code and use.
// Unfortunately, regular JavaScript means that all variables and functions
// are in the global namespace. There can be collisions with other code libraries
// which may have similar variable or function names. Collisions cause bugs as each
// library changes a variable's definition or functionality unexpectedly.
// As a result, we thought it wise to switch to an "object oriented" style of code.
// This 'literal notation' technique keeps all MobileESP variables and functions fully self-contained.
// It avoids potential for collisions with other JavaScript libraries.
// This technique allows the developer continued access to any desired function or property.
//
// Please send feedback to project founder Anthony Hand: anthony.hand@gmail.com
//
//
// File version 2015.05.13 (May 13, 2015)
// Updates:
//	- Moved MobileESP to GitHub. https://github.com/ahand/mobileesp
//	- Opera Mobile/Mini browser has the same UA string on multiple platforms and doesn't differentiate phone vs. tablet. 
//		- Removed DetectOperaAndroidPhone(). This method is no longer reliable. 
//		- Removed DetectOperaAndroidTablet(). This method is no longer reliable. 
//	- Added support for Windows Phone 10: variable and DetectWindowsPhone10()
//	- Updated DetectWindowsPhone() to include WP10. 
//	- Added support for Firefox OS.  
//		- A variable plus DetectFirefoxOS(), DetectFirefoxOSPhone(), DetectFirefoxOSTablet()
//		- NOTE: Firefox doesn't add UA tokens to definitively identify Firefox OS vs. their browsers on other mobile platforms.
//	- Added support for Sailfish OS. Not enough info to add a tablet detection method at this time. 
//		- A variable plus DetectSailfish(), DetectSailfishPhone()
//	- Added support for Ubuntu Mobile OS. 
//		- DetectUbuntu(), DetectUbuntuPhone(), DetectUbuntuTablet()
//	- Added support for 2 smart TV OSes. They lack browsers but do have WebViews for use by HTML apps. 
//		- One variable for Samsung Tizen TVs, plus DetectTizenTV()
//		- One variable for LG WebOS TVs, plus DetectWebOSTV()
//	- Updated DetectTizen(). Now tests for “mobile” to disambiguate from Samsung Smart TVs
//	- Removed variables for obsolete devices: deviceHtcFlyer, deviceXoom.
//	- Updated DetectAndroid(). No longer has a special test case for the HTC Flyer tablet. 
//	- Updated DetectAndroidPhone(). 
//		- Updated internal detection code for Android. 
//		- No longer has a special test case for the HTC Flyer tablet. 
//		- Checks against DetectOperaMobile() on Android and reports here if relevant. 
//	- Updated DetectAndroidTablet(). 
//		- No longer has a special test case for the HTC Flyer tablet. 
//		- Checks against DetectOperaMobile() on Android to exclude it from here.
//	- DetectMeego(): Changed definition for this method. Now detects any Meego OS device, not just phones. 
//	- DetectMeegoPhone(): NEW. For Meego phones. Ought to detect Opera browsers on Meego, as well.  
//	- DetectTierIphone(): Added support for phones running Sailfish, Ubuntu and Firefox Mobile. 
//	- DetectTierTablet(): Added support for tablets running Ubuntu and Firefox Mobile. 
//	- DetectSmartphone(): Added support for Meego phones. 
//	- Reorganized DetectMobileQuick(). Moved the following to DetectMobileLong():
//		- DetectDangerHiptop(), DetectMaemoTablet(), DetectSonyMylo(), DetectArchos()
//       
//
//
// LICENSE INFORMATION
// Licensed under the Apache License, Version 2.0 (the "License"); 
// you may not use this file except in compliance with the License. 
// You may obtain a copy of the License at 
//        http://www.apache.org/licenses/LICENSE-2.0 
// Unless required by applicable law or agreed to in writing, 
// software distributed under the License is distributed on an 
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific 
// language governing permissions and limitations under the License. 
//
//
// ABOUT THIS PROJECT
//   Project Owner: Anthony Hand
//   Email: anthony.hand@gmail.com
//   Web Site: http://www.mobileesp.com
//   Source Files: https://github.com/ahand/mobileesp
//   
//   Versions of this code are available for:
//      PHP, JavaScript, Java, ASP.NET (C#), Ruby and others
//
//
// WARNING: 
//   These JavaScript-based device detection features may ONLY work 
//   for the newest generation of smartphones, such as the iPhone, 
//   Android and Palm WebOS devices.
//   These device detection features may NOT work for older smartphones 
//   which had poor support for JavaScript, including 
//   older BlackBerry, PalmOS, and Windows Mobile devices. 
//   Additionally, because JavaScript support is extremely poor among 
//   'feature phones', these features may not work at all on such devices.
//   For better results, consider using a server-based version of this code, 
//   such as Java, APS.NET, PHP, or Ruby.
//
// *******************************************
*/


var MobileEsp = {

	//GLOBALLY USEFUL VARIABLES
	//Note: These values are set automatically during the Init function.
	//Stores whether we're currently initializing the most popular functions.
	initCompleted : false,
	isWebkit : false, //Stores the result of DetectWebkit()
	isMobilePhone : false, //Stores the result of DetectMobileQuick()
	isIphone : false, //Stores the result of DetectIphone()
	isAndroid : false, //Stores the result of DetectAndroid()
	isAndroidPhone : false, //Stores the result of DetectAndroidPhone()
	isTierTablet : false, //Stores the result of DetectTierTablet()
	isTierIphone : false, //Stores the result of DetectTierIphone()
	isTierRichCss : false, //Stores the result of DetectTierRichCss()
	isTierGenericMobile : false, //Stores the result of DetectTierOtherPhones()
	
	//INTERNALLY USED DETECTION STRING VARIABLES
	engineWebKit : 'webkit',
	deviceIphone : 'iphone',
	deviceIpod : 'ipod',
	deviceIpad : 'ipad',
	deviceMacPpc : 'macintosh', //Used for disambiguation
	
	deviceAndroid : 'android',
	deviceGoogleTV : 'googletv',
	
	deviceWinPhone7 : 'windows phone os 7', 
	deviceWinPhone8 : 'windows phone 8', 
	deviceWinPhone10 : 'windows phone 10', 
	deviceWinMob : 'windows ce',
	deviceWindows : 'windows',
	deviceIeMob : 'iemobile',
	devicePpc : 'ppc', //Stands for PocketPC
	enginePie : 'wm5 pie',  //An old Windows Mobile

	deviceBB : 'blackberry',
	deviceBB10 : 'bb10', //For the new BB 10 OS
	vndRIM : 'vnd.rim', //Detectable when BB devices emulate IE or Firefox
	deviceBBStorm : 'blackberry95', //Storm 1 and 2
	deviceBBBold : 'blackberry97', //Bold 97x0 (non-touch)
	deviceBBBoldTouch : 'blackberry 99', //Bold 99x0 (touchscreen)
	deviceBBTour : 'blackberry96', //Tour
	deviceBBCurve : 'blackberry89', //Curve 2
	deviceBBCurveTouch : 'blackberry 938', //Curve Touch 9380
	deviceBBTorch : 'blackberry 98', //Torch
	deviceBBPlaybook : 'playbook', //PlayBook tablet

	deviceSymbian : 'symbian',
	deviceSymbos : 'symbos', //Opera 10 on Symbian
	deviceS60 : 'series60',
	deviceS70 : 'series70',
	deviceS80 : 'series80',
	deviceS90 : 'series90',

	devicePalm : 'palm',
	deviceWebOS : 'webos', //For Palm devices 
	deviceWebOStv : 'web0s', //For LG TVs
	deviceWebOShp : 'hpwos', //For HP's line of WebOS devices

	deviceNuvifone : 'nuvifone', //Garmin Nuvifone
	deviceBada : 'bada', //Samsung's Bada OS
	deviceTizen : 'tizen', //Tizen OS
	deviceMeego : 'meego', //Meego OS
	deviceSailfish : 'sailfish', //Sailfish OS
	deviceUbuntu : 'ubuntu', //Ubuntu Mobile OS

	deviceKindle : 'kindle', //Amazon eInk Kindle
	engineSilk : 'silk-accelerated', //Amazon's accelerated Silk browser for Kindle Fire

	engineBlazer : 'blazer', //Old Palm browser
	engineXiino : 'xiino',
	
	//Initialize variables for mobile-specific content.
	vndwap : 'vnd.wap',
	wml : 'wml',
	
	//Initialize variables for random devices and mobile browsers.
	//Some of these may not support JavaScript
	deviceTablet : 'tablet',
	deviceBrew : 'brew',
	deviceDanger : 'danger',
	deviceHiptop : 'hiptop',
	devicePlaystation : 'playstation',
	devicePlaystationVita : 'vita',
	deviceNintendoDs : 'nitro',
	deviceNintendo : 'nintendo',
	deviceWii : 'wii',
	deviceXbox : 'xbox',
	deviceArchos : 'archos',
	
	engineFirefox : 'firefox', //For Firefox OS
	engineOpera : 'opera', //Popular browser
	engineNetfront : 'netfront', //Common embedded OS browser
	engineUpBrowser : 'up.browser', //common on some phones
	deviceMidp : 'midp', //a mobile Java technology
	uplink : 'up.link',
	engineTelecaQ : 'teleca q', //a modern feature phone browser
	engineObigo : 'obigo', //W 10 is a modern feature phone browser
	
	devicePda : 'pda',
	mini : 'mini',  //Some mobile browsers put 'mini' in their names
	mobile : 'mobile', //Some mobile browsers put 'mobile' in their user agent strings
	mobi : 'mobi', //Some mobile browsers put 'mobi' in their user agent strings
	
	//Smart TV strings
	smartTV1 : 'smart-tv', //Samsung Tizen smart TVs
	smartTV2 : 'smarttv', //LG WebOS smart TVs

	//Use Maemo, Tablet, and Linux to test for Nokia's Internet Tablets.
	maemo : 'maemo',
	linux : 'linux',
	mylocom2 : 'sony/com', // for Sony Mylo 1 and 2
	
	//In some UserAgents, the only clue is the manufacturer
	manuSonyEricsson : 'sonyericsson',
	manuericsson : 'ericsson',
	manuSamsung1 : 'sec-sgh',
	manuSony : 'sony',
	manuHtc : 'htc', //Popular Android and WinMo manufacturer
	
	//In some UserAgents, the only clue is the operator
	svcDocomo : 'docomo',
	svcKddi : 'kddi',
	svcVodafone : 'vodafone',
	
	//Disambiguation strings.
	disUpdate : 'update', //pda vs. update
	
	//Holds the User Agent string value.
	uagent : '',
   
	//Initializes key MobileEsp variables
	InitDeviceScan : function() {
		this.initCompleted = false;
		
		if (navigator && navigator.userAgent)
			this.uagent = navigator.userAgent.toLowerCase();
		
		//Save these properties to speed processing
		this.isWebkit = this.DetectWebkit();
		this.isIphone = this.DetectIphone();
		this.isAndroid = this.DetectAndroid();
		this.isAndroidPhone = this.DetectAndroidPhone();
		
		//Generally, these tiers are the most useful for web development
		this.isMobilePhone = this.DetectMobileQuick();
		this.isTierIphone = this.DetectTierIphone();
		this.isTierTablet = this.DetectTierTablet();
		
		//Optional: Comment these out if you NEVER use them
		this.isTierRichCss = this.DetectTierRichCss();
		this.isTierGenericMobile = this.DetectTierOtherPhones();
		
		this.initCompleted = true;
	},


	//APPLE IOS

	//**************************
	// Detects if the current device is an iPhone.
	DetectIphone : function() {
        if (this.initCompleted || this.isIphone)
			return this.isIphone;

		if (this.uagent.search(this.deviceIphone) > -1)
			{
				//The iPad and iPod Touch say they're an iPhone! So let's disambiguate.
				if (this.DetectIpad() || this.DetectIpod())
					return false;
				//Yay! It's an iPhone!
				else 
					return true;
			}
		else
			return false;
	},

	//**************************
	// Detects if the current device is an iPod Touch.
	DetectIpod : function() {
			if (this.uagent.search(this.deviceIpod) > -1)
				return true;
			else
				return false;
	},

	//**************************
	// Detects if the current device is an iPhone or iPod Touch.
	DetectIphoneOrIpod : function() {
		//We repeat the searches here because some iPods 
		//  may report themselves as an iPhone, which is ok.
		if (this.DetectIphone() || this.DetectIpod())
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is an iPad tablet.
	DetectIpad : function() {
		if (this.uagent.search(this.deviceIpad) > -1  && this.DetectWebkit())
			return true;
		else
			return false;
	},

	//**************************
	// Detects *any* iOS device: iPhone, iPod Touch, iPad.
	DetectIos : function() {
		if (this.DetectIphoneOrIpod() || this.DetectIpad())
			return true;
		else
			return false;
	},


	//ANDROID

	//**************************
	// Detects *any* Android OS-based device: phone, tablet, and multi-media player.
	// Also detects Google TV.
	DetectAndroid : function() {
		if (this.initCompleted || this.isAndroid)
			return this.isAndroid;
		
		if ((this.uagent.search(this.deviceAndroid) > -1) || this.DetectGoogleTV())
			return true;
		
		return false;
	},

	//**************************
	// Detects if the current device is a (small-ish) Android OS-based device
	// used for calling and/or multi-media (like a Samsung Galaxy Player).
	// Google says these devices will have 'Android' AND 'mobile' in user agent.
	// Ignores tablets (Honeycomb and later).
	DetectAndroidPhone : function() {
		if (this.initCompleted || this.isAndroidPhone)
			return this.isAndroidPhone;
		
		//First, let's make sure we're on an Android device.
		if (!this.DetectAndroid())
			return false;
		
		//If it's Android and has 'mobile' in it, Google says it's a phone.
		if (this.uagent.search(this.mobile) > -1)
			return true;

		//Special check for Android phones with Opera Mobile. They should report here.
		if (this.DetectOperaMobile())
			return true;
		
		return false;
	},

	//**************************
	// Detects if the current device is a (self-reported) Android tablet.
	// Google says these devices will have 'Android' and NOT 'mobile' in their user agent.
	DetectAndroidTablet : function() {
		//First, let's make sure we're on an Android device.
		if (!this.DetectAndroid())
			return false;
		
		//Special check for Opera Android Phones. They should NOT report here.
		if (this.DetectOperaMobile())
			return false;
			
		//Otherwise, if it's Android and does NOT have 'mobile' in it, Google says it's a tablet.
		if (this.uagent.search(this.mobile) > -1)
			return false;
		else
			return true;
	},

	//**************************
	// Detects if the current device is an Android OS-based device and
	//   the browser is based on WebKit.
	DetectAndroidWebKit : function() {
		if (this.DetectAndroid() && this.DetectWebkit())
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is a GoogleTV.
	DetectGoogleTV : function() {
		if (this.uagent.search(this.deviceGoogleTV) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is based on WebKit.
	DetectWebkit : function() {
		if (this.initCompleted || this.isWebkit)
			return this.isWebkit;
		
		if (this.uagent.search(this.engineWebKit) > -1)
			return true;
		else
			return false;
	},


	//WINDOWS MOBILE AND PHONE

    // Detects if the current browser is a 
    // Windows Phone 7, 8, or 10 device.
    DetectWindowsPhone : function() {
		if (this.DetectWindowsPhone7() ||
            this.DetectWindowsPhone8() ||
            this.DetectWindowsPhone10())
			return true;
		else
			return false;
	},

	//**************************
	// Detects a Windows Phone 7 device (in mobile browsing mode).
	DetectWindowsPhone7 : function() { 
		if (this.uagent.search(this.deviceWinPhone7) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a Windows Phone 8 device (in mobile browsing mode).
	DetectWindowsPhone8 : function() {
		if (this.uagent.search(this.deviceWinPhone8) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a Windows Phone 10 device (in mobile browsing mode).
	DetectWindowsPhone10 : function() {
		if (this.uagent.search(this.deviceWinPhone10) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is a Windows Mobile device.
	// Excludes Windows Phone 7 and later devices. 
	// Focuses on Windows Mobile 6.xx and earlier.
	DetectWindowsMobile : function() {
		if (this.DetectWindowsPhone())
			return false;

		//Most devices use 'Windows CE', but some report 'iemobile' 
		//  and some older ones report as 'PIE' for Pocket IE. 
		if (this.uagent.search(this.deviceWinMob) > -1 ||
			this.uagent.search(this.deviceIeMob) > -1 ||
			this.uagent.search(this.enginePie) > -1)
			return true;
		//Test for Windows Mobile PPC but not old Macintosh PowerPC.
		if ((this.uagent.search(this.devicePpc) > -1) && 
			!(this.uagent.search(this.deviceMacPpc) > -1))
			return true;
		//Test for Windwos Mobile-based HTC devices.
		if (this.uagent.search(this.manuHtc) > -1 &&
			this.uagent.search(this.deviceWindows) > -1)
			return true;
		else
			return false;
	},


	//BLACKBERRY

	//**************************
	// Detects if the current browser is a BlackBerry of some sort.
	// Includes BB10 OS, but excludes the PlayBook.
	DetectBlackBerry : function() {
		if ((this.uagent.search(this.deviceBB) > -1) ||
			(this.uagent.search(this.vndRIM) > -1))
			return true;
		if (this.DetectBlackBerry10Phone())
			return true;
		else
			return false;
	},

	//**************************
        // Detects if the current browser is a BlackBerry 10 OS phone.
        // Excludes tablets.
	DetectBlackBerry10Phone : function() {
		if ((this.uagent.search(this.deviceBB10) > -1) &&
			(this.uagent.search(this.mobile) > -1))
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is on a BlackBerry tablet device.
	//    Example: PlayBook
	DetectBlackBerryTablet : function() {
		if (this.uagent.search(this.deviceBBPlaybook) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is a BlackBerry device AND uses a
	//    WebKit-based browser. These are signatures for the new BlackBerry OS 6.
	//    Examples: Torch. Includes the Playbook.
	DetectBlackBerryWebKit : function() {
		if (this.DetectBlackBerry() &&
			this.uagent.search(this.engineWebKit) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is a BlackBerry Touch
	//    device, such as the Storm, Torch, and Bold Touch. Excludes the Playbook.
	DetectBlackBerryTouch : function() {
		if (this.DetectBlackBerry() &&
			((this.uagent.search(this.deviceBBStorm) > -1) ||
			(this.uagent.search(this.deviceBBTorch) > -1) ||
			(this.uagent.search(this.deviceBBBoldTouch) > -1) ||
			(this.uagent.search(this.deviceBBCurveTouch) > -1) ))
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is a BlackBerry OS 5 device AND
	//    has a more capable recent browser. Excludes the Playbook.
	//    Examples, Storm, Bold, Tour, Curve2
	//    Excludes the new BlackBerry OS 6 and 7 browser!!
	DetectBlackBerryHigh : function() {
		//Disambiguate for BlackBerry OS 6 or 7 (WebKit) browser
		if (this.DetectBlackBerryWebKit())
			return false;
		if ((this.DetectBlackBerry()) &&
			(this.DetectBlackBerryTouch() ||
			this.uagent.search(this.deviceBBBold) > -1 || 
			this.uagent.search(this.deviceBBTour) > -1 || 
			this.uagent.search(this.deviceBBCurve) > -1))
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is a BlackBerry device AND
	//    has an older, less capable browser. 
	//    Examples: Pearl, 8800, Curve1.
	DetectBlackBerryLow : function() {
		if (this.DetectBlackBerry())
		{
			//Assume that if it's not in the High tier or has WebKit, then it's Low.
			if (this.DetectBlackBerryHigh() || this.DetectBlackBerryWebKit())
				return false;
			else
				return true;
		}
		else
			return false;
	},


	//SYMBIAN

	//**************************
	// Detects if the current browser is the Nokia S60 Open Source Browser.
	DetectS60OssBrowser : function() {
		if (this.DetectWebkit())
		{
			if ((this.uagent.search(this.deviceS60) > -1 || 
				this.uagent.search(this.deviceSymbian) > -1))
				return true;
			else
				return false;
		}
		else
			return false;
	}, 

	//**************************
	// Detects if the current device is any Symbian OS-based device,
	//   including older S60, Series 70, Series 80, Series 90, and UIQ, 
	//   or other browsers running on these devices.
	DetectSymbianOS : function() {
		if (this.uagent.search(this.deviceSymbian) > -1 ||
			this.uagent.search(this.deviceS60) > -1 ||
			((this.uagent.search(this.deviceSymbos) > -1) &&
				(this.DetectOperaMobile)) || //Opera 10
			this.uagent.search(this.deviceS70) > -1 ||
			this.uagent.search(this.deviceS80) > -1 ||
			this.uagent.search(this.deviceS90) > -1)
			return true;
		else
			return false;
	},


	//WEBOS AND PALM

	//**************************
	// Detects if the current browser is on a PalmOS device.
	DetectPalmOS : function() {
		//Make sure it's not WebOS first
		if (this.DetectPalmWebOS())
			return false;

		//Most devices nowadays report as 'Palm', 
		//  but some older ones reported as Blazer or Xiino.
		if (this.uagent.search(this.devicePalm) > -1 ||
			this.uagent.search(this.engineBlazer) > -1 ||
			this.uagent.search(this.engineXiino) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is on a Palm device
	//   running the new WebOS.
	DetectPalmWebOS : function()
	{
		if (this.uagent.search(this.deviceWebOS) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is on an HP tablet running WebOS.
	DetectWebOSTablet : function() {
		if (this.uagent.search(this.deviceWebOShp) > -1 &&
			this.uagent.search(this.deviceTablet) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is on a WebOS smart TV.
	DetectWebOSTV : function() {
		if (this.uagent.search(this.deviceWebOStv) > -1 &&
			this.uagent.search(this.smartTV2) > -1)
			return true;
		else
			return false;
	},


	//OPERA

	//**************************
	// Detects if the current browser is Opera Mobile or Mini.
	// Note: Older embedded Opera on mobile devices didn't follow these naming conventions.
	//   Like Archos media players, they will probably show up in DetectMobileQuick or -Long instead. 
	DetectOperaMobile : function() {
		if ((this.uagent.search(this.engineOpera) > -1) &&
			((this.uagent.search(this.mini) > -1 ||
			this.uagent.search(this.mobi) > -1)))
			return true;
		else
			return false;
	},


	//MISCELLANEOUS DEVICES

	//**************************
	// Detects if the current device is an Amazon Kindle (eInk devices only).
	// Note: For the Kindle Fire, use the normal Android methods.
	DetectKindle : function() {
		if (this.uagent.search(this.deviceKindle) > -1 &&
			!this.DetectAndroid())
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current Amazon device has turned on the Silk accelerated browsing feature.
	// Note: Typically used by the the Kindle Fire.
	DetectAmazonSilk : function() {
		if (this.uagent.search(this.engineSilk) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is a
	//   Garmin Nuvifone.
	DetectGarminNuvifone : function() {
		if (this.uagent.search(this.deviceNuvifone) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a device running the Bada OS from Samsung.
	DetectBada : function() {
		if (this.uagent.search(this.deviceBada) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a device running the Tizen smartphone OS.
	DetectTizen : function() {
		if (this.uagent.search(this.deviceTizen) > -1 &&
			this.uagent.search(this.mobile) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is on a Tizen smart TV.
	DetectTizenTV : function() {
		if (this.uagent.search(this.deviceTizen) > -1 &&
			this.uagent.search(this.smartTV1) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a device running the Meego OS.
	DetectMeego : function() {
		if (this.uagent.search(this.deviceMeego) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a phone running the Meego OS.
	DetectMeegoPhone : function() {
		if (this.uagent.search(this.deviceMeego) > -1 &&
			this.uagent.search(this.mobi) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a mobile device (probably) running the Firefox OS.
	DetectFirefoxOS : function() {
		if (this.DetectFirefoxOSPhone() || this.DetectFirefoxOSTablet())
			return true;
		else
			return false;
	},

	//**************************
	// Detects a phone (probably) running the Firefox OS.
	DetectFirefoxOSPhone : function() {
		//First, let's make sure we're NOT on another major mobile OS.
		if (this.DetectIos() || 
			this.DetectAndroid() ||
			this.DetectSailfish())
			return false;    	  

		if ((this.uagent.search(this.engineFirefox) > -1) && 
			(this.uagent.search(this.mobile) > -1))
			return true;
		
		return false;
	},

	//**************************
	// Detects a tablet (probably) running the Firefox OS.
	DetectFirefoxOSTablet : function() {
		//First, let's make sure we're NOT on another major mobile OS.
		if (this.DetectIos() || 
			this.DetectAndroid() ||
			this.DetectSailfish())
			return false;    	  

		if ((this.uagent.search(this.engineFirefox) > -1) && 
			(this.uagent.search(this.deviceTablet) > -1))
			return true;
		
		return false;
	},

	//**************************
	// Detects a device running the Sailfish OS.
	DetectSailfish : function() {
		if (this.uagent.search(this.deviceSailfish) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects a phone running the Sailfish OS.
	DetectSailfishPhone : function() {
		if (this.DetectSailfish() && (this.uagent.search(this.mobile) > -1))
			return true;
		
		return false;
	},


	//**************************
	// Detects a mobile device running the Ubuntu Mobile OS.
	DetectUbuntu : function() {
		if (this.DetectUbuntuPhone() || this.DetectUbuntuTablet())
			return true;
		else
			return false;
	},

	//**************************
	// Detects a phone running the Ubuntu Mobile OS.
	DetectUbuntuPhone : function() {
		if ((this.uagent.search(this.deviceUbuntu) > -1) && 
			(this.uagent.search(this.mobile) > -1))
			return true;
		
		return false;
	},

	//**************************
	// Detects a tablet running the Ubuntu Mobile OS.
	DetectUbuntuTablet : function() {
		if ((this.uagent.search(this.deviceUbuntu) > -1) && 
			(this.uagent.search(this.deviceTablet) > -1))
			return true;
		
		return false;
	},

	//**************************
	// Detects the Danger Hiptop device.
	DetectDangerHiptop : function() {
		if (this.uagent.search(this.deviceDanger) > -1 ||
			this.uagent.search(this.deviceHiptop) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current browser is a Sony Mylo device.
	DetectSonyMylo : function() {
		if ((this.uagent.search(this.manuSony) > -1) &&
                    ((this.uagent.search(this.qtembedded) > -1) ||
                     (this.uagent.search(this.mylocom2) > -1)))
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is on one of 
	// the Maemo-based Nokia Internet Tablets.
	DetectMaemoTablet : function() {
		if (this.uagent.search(this.maemo) > -1)
			return true;
		//For Nokia N810, must be Linux + Tablet, or else it could be something else.
		if ((this.uagent.search(this.linux) > -1) && 
			(this.uagent.search(this.deviceTablet) > -1) && 
			this.DetectWebOSTablet() && 
			!this.DetectAndroid())
			return true;
		else
			return false;
	},

        //**************************
	// Detects if the current device is an Archos media player/Internet tablet.
	DetectArchos : function() {
		if (this.uagent.search(this.deviceArchos) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is an Internet-capable game console.
	// Includes many handheld consoles.
	DetectGameConsole : function() {
		if (this.DetectSonyPlaystation() || 
			this.DetectNintendo() ||
			this.DetectXbox())
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is a Sony Playstation.
	DetectSonyPlaystation : function() {
		if (this.uagent.search(this.devicePlaystation) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is a handheld gaming device with
    // a touchscreen and modern iPhone-class browser. Includes the Playstation Vita.
	DetectGamingHandheld : function() {
		if ((this.uagent.search(this.devicePlaystation) > -1) &&
                   (this.uagent.search(this.devicePlaystationVita) > -1))
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is a Nintendo game device.
	DetectNintendo : function() {
		if (this.uagent.search(this.deviceNintendo) > -1   || 
			this.uagent.search(this.deviceWii) > -1 ||
			this.uagent.search(this.deviceNintendoDs) > -1)
			return true;
		else
			return false;
	},

	//**************************
	// Detects if the current device is a Microsoft Xbox.
	DetectXbox : function() {
		if (this.uagent.search(this.deviceXbox) > -1)
			return true;
		else
			return false;
	},
        
        
	//**************************
	// Detects whether the device is a Brew-powered device.
	//   Note: Limited to older Brew-powered feature phones.
	//   Ignores newer Brew versions like MP. Refer to DetectMobileQuick().
	DetectBrewDevice : function() {
		if (this.uagent.search(this.deviceBrew) > -1)
			return true;
		else
			return false;
	},


	// DEVICE CLASSES

	//**************************
	// Check to see whether the device is *any* 'smartphone'.
	//   Note: It's better to use DetectTierIphone() for modern touchscreen devices. 
	DetectSmartphone : function() {
		//Exclude duplicates from TierIphone
        if (this.DetectTierIphone() ||
            this.DetectS60OssBrowser() ||
			this.DetectSymbianOS() ||
			this.DetectWindowsMobile() ||
			this.DetectBlackBerry() ||
			this.DetectMeegoPhone() ||
			this.DetectPalmOS())
			return true;
		
		//Otherwise, return false.
		return false;
	},

	//**************************
	// Detects if the current device is a mobile device.
	//  This method catches most of the popular modern devices.
	//  Excludes Apple iPads and other modern tablets.
	DetectMobileQuick : function() {
		if (this.initCompleted || this.isMobilePhone)
			return this.isMobilePhone;

		//Let's exclude tablets.
		if (this.DetectTierTablet())
			return false;

		//Most mobile browsing is done on smartphones
		if (this.DetectSmartphone())
			return true;

		//Catch-all for many mobile devices
		if (this.uagent.search(this.mobile) > -1)
			return true;

		if (this.DetectOperaMobile())
			return true;

		//We also look for Kindle devices
		if (this.DetectKindle() ||
			this.DetectAmazonSilk())
			return true;

		if (this.uagent.search(this.deviceMidp) > -1 ||
			this.DetectBrewDevice())
			return true;

		if ((this.uagent.search(this.engineObigo) > -1) ||
			(this.uagent.search(this.engineNetfront) > -1) ||
			(this.uagent.search(this.engineUpBrowser) > -1))
			return true;

		return false;
	},

	//**************************
	// Detects in a more comprehensive way if the current device is a mobile device.
	DetectMobileLong : function() {
		if (this.DetectMobileQuick())
			return true;
		if (this.DetectGameConsole())
			return true;

		if (this.DetectDangerHiptop() ||
			this.DetectMaemoTablet() ||
			this.DetectSonyMylo() ||
			this.DetectArchos())
			return true;

		if ((this.uagent.search(this.devicePda) > -1) &&
			!(this.uagent.search(this.disUpdate) > -1)) 
			return true;
		
		//Detect for certain very old devices with stupid useragent strings.
		if ((this.uagent.search(this.manuSamsung1) > -1) ||
			(this.uagent.search(this.manuSonyEricsson) > -1) || 
			(this.uagent.search(this.manuericsson) > -1) ||
			(this.uagent.search(this.svcDocomo) > -1) ||
			(this.uagent.search(this.svcKddi) > -1) ||
			(this.uagent.search(this.svcVodafone) > -1))
			return true;
		
		return false;
	},

	//*****************************
	// For Mobile Web Site Design
	//*****************************
	
	//**************************
	// The quick way to detect for a tier of devices.
	//   This method detects for the new generation of
	//   HTML 5 capable, larger screen tablets.
	//   Includes iPad, Android (e.g., Xoom), BB Playbook, WebOS, etc.
	DetectTierTablet : function() {
		if (this.initCompleted || this.isTierTablet)
			return this.isTierTablet;
		
		if (this.DetectIpad() ||
			this.DetectAndroidTablet() ||
			this.DetectBlackBerryTablet() ||
			this.DetectFirefoxOSTablet() ||
			this.DetectUbuntuTablet() ||
			this.DetectWebOSTablet())
			return true;
		else
			return false;
	},

	//**************************
	// The quick way to detect for a tier of devices.
	//   This method detects for devices which can 
	//   display iPhone-optimized web content.
	//   Includes iPhone, iPod Touch, Android, Windows Phone 7 and 8, BB10, WebOS, Playstation Vita, etc.
	DetectTierIphone : function() {
		if (this.initCompleted || this.isTierIphone)
			return this.isTierIphone;

		if (this.DetectIphoneOrIpod() ||
                        this.DetectAndroidPhone() ||
			this.DetectWindowsPhone() ||
			this.DetectBlackBerry10Phone() ||
			this.DetectPalmWebOS() ||
			this.DetectBada() ||
			this.DetectTizen() ||
			this.DetectFirefoxOSPhone() ||
			this.DetectSailfishPhone() ||
			this.DetectUbuntuPhone() ||
			this.DetectGamingHandheld())
			return true;

        //Note: BB10 phone is in the previous paragraph
		if (this.DetectBlackBerryWebKit() && this.DetectBlackBerryTouch())
			return true;
		
		else
			return false;
	},

	//**************************
	// The quick way to detect for a tier of devices.
	//   This method detects for devices which are likely to be 
	//   capable of viewing CSS content optimized for the iPhone, 
	//   but may not necessarily support JavaScript.
	//   Excludes all iPhone Tier devices.
	DetectTierRichCss : function() {
		if (this.initCompleted || this.isTierRichCss)
			return this.isTierRichCss;

		//Exclude iPhone and Tablet Tiers and e-Ink Kindle devices
		if (this.DetectTierIphone() ||
			this.DetectKindle() ||
			this.DetectTierTablet())
			return false;
		
		//Exclude if not mobile
		if (!this.DetectMobileQuick())
			return false;
				
		//If it's a mobile webkit browser on any other device, it's probably OK.
		if (this.DetectWebkit())
			return true;
		
		//The following devices are also explicitly ok.
		if (this.DetectS60OssBrowser() ||
			this.DetectBlackBerryHigh() ||
			this.DetectWindowsMobile() ||
			(this.uagent.search(this.engineTelecaQ) > -1))
			return true;
		
		else
			return false;
	},

	//**************************
	// The quick way to detect for a tier of devices.
	//   This method detects for all other types of phones,
	//   but excludes the iPhone and RichCSS Tier devices.
	// NOTE: This method probably won't work due to poor
	//  support for JavaScript among other devices. 
	DetectTierOtherPhones : function() {
		if (this.initCompleted || this.isTierGenericMobile)
			return this.isTierGenericMobile;
		
		//Exclude iPhone, Rich CSS and Tablet Tiers
		if (this.DetectTierIphone() ||
			this.DetectTierRichCss() ||
			this.DetectTierTablet())
			return false;
		
		//Otherwise, if it's mobile, it's OK
		if (this.DetectMobileLong())
			return true;

		else
			return false;
	}

};

//Initialize the MobileEsp object
MobileEsp.InitDeviceScan();



