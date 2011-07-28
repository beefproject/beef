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
class Detect_scripts_support < BeEF::Core::Command
  
  def callback
    content = {}    
    content['Java enabled'] =  @datastore['java_enabled']
    content['VBscript enabled'] = @datastore['vbscript_enabled']
    content['Has Flash'] = @datastore['has_flash']
    content['Has Google Gears'] = @datastore['has_googlegears']
    
    save content
    #update_zombie!
  end
  
end
