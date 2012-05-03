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
class Google_search < BeEF::Core::Command

	def self.options
		return [
			{'name' => 'query', 'ui_label' => 'Query', 'type' => 'textarea', 'value' =>'beef', 'width' => '400px', 'height' => '50px'}
		]
	end

	def post_execute
		content = {}
		content['results'] = @datastore['results']
		content['query'] = @datastore['query']
		save content
	end

end

