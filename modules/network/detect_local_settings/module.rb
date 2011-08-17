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
class Detect_local_settings < BeEF::Core::Command
  
  def pre_send
    #Mount the Beeffeine.class on /Beeffeine.class
    #Unsure if there's something we can add here to check if the module was already mounted?
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/network/detect_local_settings/Beeffeine.class','/Beeffeine','class')
  end
  
  def post_execute
    content = {}
    content['internal ip'] = @datastore['internal_ip'] if not @datastore['internal_ip'].nil?
    content['internal hostname'] = @datastore['internal_hostname'] if not @datastore['internal_hostname'].nil?
    
    content['fail'] = 'could not grab local network settings' if content.empty?
    
    #Unmount the class now, it's no longer required.
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/Beeffeine.class');
    
    save content
  end
  
end
