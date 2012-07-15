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

  #todo antisnatchor: reverted for now
  #def pre_send
  #  BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_socket("IRC", "0.0.0.0", 6667)
  #end

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

    #todo antisnatchor: how long should we leave it open? Maybe default timeout of 30 seconds?
    #BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind_socket("IRC")

  end
  
end
