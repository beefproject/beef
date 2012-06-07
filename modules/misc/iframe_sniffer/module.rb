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
class Iframe_sniffer < BeEF::Core::Command

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/misc/iframe_sniffer/leakyframe.js','/leakyframe','js')
  end 
 
  def self.options
    return [
        {'name' => 'inputUrl', 'ui_label'=>'input URL', 'type' => 'textarea', 'value' =>'http://en.wikipedia.org/wiki/Beef', 'width' => '400px', 'height' => '50px'},
        {'name' => 'anchorsToCheck', 'ui_label' => 'anchors to check', 'value' => 'History,Exploit,Etymology,References,ABCDE', 'type' => 'textarea', 'width' => '400px', 'height' => '100px' }
    ]
  end
  
  def post_execute
    content = {}
    content['resultList'] = @datastore['resultList']
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('leakyframe.js')
    save content
  end
  
end
