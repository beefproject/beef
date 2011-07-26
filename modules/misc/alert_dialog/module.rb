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
class Alert_dialog < BeEF::Core::Command
  
  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Alert Dialog',
      'Description' => 'Sends an alert dialog to the victim',
      'Category' => 'Misc',
      'Author' => 'bm',
      'Data' => [
        {'name' => 'text', 'ui_label'=>'Alert text', 'type' => 'textarea', 'value' =>'BeEF', 'width' => '400px', 'height' => '100px'}
      ],
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY, 
      'browser_name' => ALL
    })
    
    # This tells the framework to use the file 'alert.js' as the command module instructions.
    use_template!
  end

 # set and return all options for this module
  def self.options
    return [{
      'name' => 'text', 
      'description' => 'Sends an alert dialog to the victim', 
      'filter' => '',
      'type' => 'textarea',
      'ui_label' => 'Alert text',
      'value' => 'Alert box text',
      'width' => '400px', 
      'height' => '100px'
      }]
  end
  
  def callback
    content = {}
    content['User Response'] = "The user clicked the 'OK' button when presented with an alert box."
    save content
  end
  
end
