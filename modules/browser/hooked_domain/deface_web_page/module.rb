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
class Deface_web_page < BeEF::Core::Command

  def self.options
	configuration = BeEF::Core::Configuration.instance
	favicon_uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/ui/media/images/favicon.ico"
    return [
		{ 'name' => 'deface_title', 'description' => 'Page Title', 'ui_label' => 'New Title', 'value' => 'BeEF - The Browser Exploitation Framework Project', 'width'=>'200px' },
		{ 'name' => 'deface_favicon', 'description' => 'Shortcut Icon', 'ui_label' => 'New Favicon', 'value' => favicon_uri, 'width'=>'200px' },
        { 'name' => 'deface_content', 'description' => 'Your defacement content', 'ui_label'=>'Deface Content', 'type' => 'textarea', 'value' =>'BeEF!', 'width' => '400px', 'height' => '100px' }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end
