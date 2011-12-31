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
class Linksys_wrt54g_csrf < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'base', 'ui_label' => 'Router web root', 'value' => 'http://arbitrary:admin@192.168.1.1/'}, 
        {'name' => 'port', 'ui_label' => 'Desired port', 'value' => '31337'}, 
        {'name' => 'password', 'ui_label' => 'Desired password', 'value' => '__BeEF__'}
    ]
  end
  
  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
