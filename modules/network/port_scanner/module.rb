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
# Port Scanner Module - javier.marcos
# Scan ports in a given hostname, using WebSockets CORS and HTTP with img tags. 
# It uses the three methods to avoid blocked ports or Same Origin Policy.


class Port_scanner < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'ipHost', 'ui_label' => 'Scan IP or Hostname', 'value' => '192.168.1.10'},
        {'name' => 'ports' , 'ui_label' => 'Specific port(s) to scan', 'value' => 'default'},
	      {'name' => 'closetimeout' , 'ui_label' => 'Closed port timeout (ms)', 'value' => '1100'},
        {'name' => 'opentimeout', 'ui_label' => 'Open port timeout (ms)', 'value' => '2500'},
        {'name' => 'delay', 'ui_label' => 'Delay between requests (ms)', 'value' => '600'},
        {'name' => 'debug', 'ui_label' => 'Debug', 'value' => 'false'}
    ]
  end
  
  def post_execute
    content = {}
    content['port'] =@datastore['port'] if not @datastore['port'].nil?
    if content.empty?
      content['fail'] = 'No open ports have been found.'
    end
    save content
  end
end
