#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
class Mobilesafari_address_spoofing < BeEF::Core::Command

	def self.options
		return [
			{'name' => 'fake_url', 'ui_label' => 'Fake URL', 'type' => 'text', 'value' =>'http://en.wikipedia.org/wiki/Beef'},
			{'name' => 'real_url', 'ui_label' => 'Real URL', 'type' => 'text', 'value' => 'http://www.beefproject.com'},
			{'name' => 'domselectah', 'ui_label' => 'jQuery Selector for Link rewriting. \'a\' will overwrite all links', 'type' => 'text', 'value' => 'a'}
		]
	end

	def post_execute
		content = {}
		content['results'] = @datastore['results']
		content['query'] = @datastore['query']
		save content
	end

end

