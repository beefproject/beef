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
class Prompt_dialog < BeEF::Core::Command
  
  def initialize
    super({
      'Name' => 'Prompt Dialog',
      'Description' => 'Sends a prompt dialog to the victim',
      'Category' => 'Misc',
      'Author' => 'bm',
      'Data' => [
        {'name' =>'question', 'ui_label'=>'Prompt text'}
      ],
      'File' => __FILE__
    })
    
    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
    })
    
    use_template!
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def callback
    
#    return if @datastore['answer']==''

    save({'answer' => @datastore['answer']})
  end
  
end