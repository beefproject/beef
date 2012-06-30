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
class Irc_nat_pinning < BeEF::Core::Command
  
  def self.options
    return [
        {'name'=>'connectto', 'ui_label' =>'Connect to','value'=>'http://attacker.com'},
        {'name'=>'privateip', 'ui_label' =>'Private IP','value'=>'192.168.0.100'},
        {'name'=>'privateport', 'ui_label' =>'Private Port','value'=>'22'}
    ]
  end
  
  def post_execute
    return if @datastore['result'].nil?
    
    save({'result' => @datastore['result']})
  end
  
end
