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
class Detect_cookies_support < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Detect Cookie Support',
      'Description' => %Q{
        This module will check if the browser allows a cookie with specified name to be set.
        },
      'Category' => 'Recon',
      'Data' => [
        {'name' => 'cookie', 'ui_label' => 'Cookie name', 'value' =>'cookie'}
      ],
      'Author' => ['vo'],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })

    use 'beef.browser.cookie'
    use_template!
  end
  
  def callback
    content = {}
    content['Has Session Cookies'] = @datastore['has_session_cookies']
    content['Has Persistent Cookies'] = @datastore['has_persistent_cookies']
    content['Cookie Attempted'] = @datastore['cookie'] 
    save content
  end

end
