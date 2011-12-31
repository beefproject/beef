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
#
# Ping Sweep Module - jgaliana
# Discover active hosts in the internal network of the hooked browser.
# It works calling a Java method from JavaScript and do not require user interaction.


class Ping_sweep_java < BeEF::Core::Command

  def pre_send
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/network/ping_sweep_java/pingSweep.class','/pingSweep','class')
	end

  def self.options
    return [
        {'name' => 'ipRange', 'ui_label' => 'Scan IP range (C class or IP)', 'value' => '192.168.0.1-192.168.0.254'},
        {'name' => 'timeout', 'ui_label' => 'Timeout (ms)', 'value' => '2000'}
    ]
  end
  
  def post_execute
    content = {}
    content['ps'] =@datastore['ps'] if not @datastore['ps'].nil?
    if content.empty?
      content['fail'] = 'No active hosts have been discovered.'
    end
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/pingSweep.class')
    save content
  end
end
