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
class Site_redirect < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Site Redirect',
      'Description' => 'This module will redirect the hooked browser to the address specified in the \'Redirect URL\' input.',
      'Category' => 'Browser',
      'Author' => ['wade', 'vo'],
      'Data' => [
        { 'ui_label'=>'Redirect URL', 'name'=>'redirect_url', 'value'=>'http://www.bindshell.net/', 'width'=>'200px' }
      ],
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
    })
              
    use_template!
  end

  def callback
    save({'result' => @datastore['result']})
  end
  
end