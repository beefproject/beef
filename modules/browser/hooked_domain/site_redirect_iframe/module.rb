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
class Site_redirect_iframe < BeEF::Core::Command
  
    def self.options
		configuration = BeEF::Core::Configuration.instance
		favicon_uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/ui/media/images/favicon.ico"
        return [
			  { 'name' => 'iframe_title', 'description' => 'Title of the iFrame', 'ui_label' => 'New Title', 'value' => 'BeEF - The Browser Exploitation Framework Project', 'width'=>'200px' },
			  { 'name' => 'iframe_favicon', 'description' => 'Shortcut Icon', 'ui_label' => 'New Favicon', 'value' => favicon_uri, 'width'=>'200px' },

			  { 'name' => 'iframe_src', 'description' => 'Source of the iFrame', 'ui_label' => 'Redirect URL', 'value' => 'http://beefproject.com/', 'width'=>'200px' },
			  { 'name' => 'iframe_timeout', 'description' => 'iFrame timeout', 'ui_label' => 'Timeout', 'value' => '3500', 'width'=>'150px' }
        ]
    end

  # This method is being called when a hooked browser sends some
  # data back to the framework.
  #
  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
