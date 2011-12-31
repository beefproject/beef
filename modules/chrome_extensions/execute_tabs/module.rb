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
class Execute_tabs < BeEF::Core::Command

  def self.options
    return [
        {'name' => 'url', 'ui_label' => 'URL', 'value' => 'https://www.google.com/accounts/EditUserInfo',  'width' => '500px'},
        {'name' => 'theJS', 'ui_label' => 'Javascript', 'value' => 'prompt(\'BeEF\');', 'type' => 'textarea', 'width' => '400px', 'height' => '300px'}
    ]
  end

  def post_execute
    content = {}
    content['Return'] = @datastore['return']
    save content
  end
  
end

