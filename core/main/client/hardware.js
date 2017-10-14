//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.hardware = {

  ua: navigator.userAgent,

  /*
   * @return: {String} CPU type
   **/
  cpuType: function() {
    var arch = 'UNKNOWN';
    // note that actually WOW64 means IE 32bit and Windows 64 bit. we are more interested
    // in detecting the OS arch rather than the browser build
    if (navigator.userAgent.match('(WOW64|x64|x86_64)') || navigator.platform.toLowerCase() == "win64"){
      arch = 'x86_64';
    }else if(typeof navigator.cpuClass != 'undefined'){
      switch (navigator.cpuClass) {
        case '68K':
          arch = 'Motorola 68K';
          break;
        case 'PPC':
          arch = 'Motorola PPC';
          break;
        case 'Digital':
          arch = 'Alpha';
          break;
        default:
          arch = 'x86';
      }
    }
    // TODO we can infer the OS is 64 bit, if we first detect the OS type (os.js).
    // For example, if OSX is at least 10.7, most certainly is 64 bit.
    return arch;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isTouchEnabled: function() {
    if ('ontouchstart' in document) return true;
    return false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isVirtualMachine: function() {
    if (screen.width % 2 || screen.height % 2) return true;
    return false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isLaptop: function() {
    // Most common laptop screen resolution
    if (screen.width == 1366 && screen.height == 768) return true;
    // Netbooks
    if (screen.width == 1024 && screen.height == 600) return true;
    return false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isNokia: function() {
    return (this.ua.match('(Maemo Browser)|(Symbian)|(Nokia)')) ? true : false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isZune: function() {
    return (this.ua.match('ZuneWP7')) ? true : false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isHtc: function() {
    return (this.ua.match('HTC')) ? true : false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isEricsson: function() {
    return (this.ua.match('Ericsson')) ? true : false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isMotorola: function() {
    return (this.ua.match('Motorola')) ? true : false;
  },

  /*
   * @return: {Boolean} true or false.
   **/
  isGoogle: function() {
    return (this.ua.match('Nexus One')) ? true : false;
  },

  /**
   * Returns true if the browser is on a Mobile device
   * @return: {Boolean} true or false
   *
   * @example: if(beef.hardware.isMobileDevice()) { ... }
   **/
  isMobileDevice: function() {
    return MobileEsp.DetectMobileQuick();
  },

  getName: function() {
    var ua = navigator.userAgent.toLowerCase();
    if(MobileEsp.DetectIphone())              { return "iPhone"};
    if(MobileEsp.DetectIpod())                { return "iPod Touch"};
    if(MobileEsp.DetectIpad())                { return "iPad"};
    if (this.isHtc())               { return 'HTC'};
    if (this.isMotorola())          { return 'Motorola'};
    if (this.isZune())              { return 'Zune'};
    if (this.isGoogle())            { return 'Google Nexus One'};
    if (this.isEricsson())          { return 'Ericsson'};
    if(MobileEsp.DetectAndroidPhone())        { return "Android Phone"};
    if(MobileEsp.DetectAndroidTablet())       { return "Android Tablet"};
    if(MobileEsp.DetectS60OssBrowser())       { return "Nokia S60 Open Source"};
    if(ua.search(MobileEsp.deviceS60) > -1)   { return "Nokia S60"};
    if(ua.search(MobileEsp.deviceS70) > -1)   { return "Nokia S70"};
    if(ua.search(MobileEsp.deviceS80) > -1)   { return "Nokia S80"};
    if(ua.search(MobileEsp.deviceS90) > -1)   { return "Nokia S90"};
    if(ua.search(MobileEsp.deviceSymbian) > -1)   { return "Nokia Symbian"};
    if (this.isNokia())             { return 'Nokia'};
    if(MobileEsp.DetectWindowsPhone7())       { return "Windows Phone 7"};
    if(MobileEsp.DetectWindowsMobile())       { return "Windows Mobile"};
    if(MobileEsp.DetectBlackBerryTablet())    { return "BlackBerry Tablet"};
    if(MobileEsp.DetectBlackBerryWebKit())    { return "BlackBerry OS 6"};
    if(MobileEsp.DetectBlackBerryTouch())     { return "BlackBerry Touch"};
    if(MobileEsp.DetectBlackBerryHigh())      { return "BlackBerry OS 5"};
    if(MobileEsp.DetectBlackBerry())          { return "BlackBerry"};
    if(MobileEsp.DetectPalmOS())              { return "Palm OS"};
    if(MobileEsp.DetectPalmWebOS())           { return "Palm Web OS"};
    if(MobileEsp.DetectGarminNuvifone())      { return "Gamin Nuvifone"};
    if(MobileEsp.DetectArchos())              { return "Archos"}
    if(MobileEsp.DetectBrewDevice())          { return "Brew"};
    if(MobileEsp.DetectDangerHiptop())        { return "Danger Hiptop"};
    if(MobileEsp.DetectMaemoTablet())         { return "Maemo Tablet"};
    if(MobileEsp.DetectSonyMylo())            { return "Sony Mylo"};
    if(MobileEsp.DetectAmazonSilk())          { return "Kindle Fire"};
    if(MobileEsp.DetectKindle())              { return "Kindle"};
    if(MobileEsp.DetectSonyPlaystation())                 { return "Playstation"};
    if(ua.search(MobileEsp.deviceNintendoDs) > -1)        { return "Nintendo DS"};
    if(ua.search(MobileEsp.deviceWii) > -1)               { return "Nintendo Wii"};
    if(ua.search(MobileEsp.deviceNintendo) > -1)          { return "Nintendo"};
    if(MobileEsp.DetectXbox())                            { return "Xbox"};
    if(this.isLaptop())                         { return "Laptop"};
    if(this.isVirtualMachine())                 { return "Virtual Machine"};

    return 'Unknown';
  }
};

beef.regCmp('beef.hardware');
