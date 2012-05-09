#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
class Clippy < BeEF::Core::Command
  
  def self.options
    return [
        {'name' =>'clippydir', 'description' =>'Webdir containing clippy image', 'ui_label'=>'Clippy image', 'value' => 'http://clippy.ajbnet.com/1.0.0/'},
        {'name' =>'askusertext', 'description' =>'Text for speech bubble', 'ui_label'=>'Custom text', 'value' => 'Your browser appears to be out of date. Would you like to upgrade it?'},
        {'name' =>'executeyes', 'description' =>'Executable to download', 'ui_label'=>'Executable', 'value' => 'http://the.earth.li/~sgtatham/putty/latest/x86/putty.exe'},
        {'name' =>'respawntime', 'description' =>'', 'ui_label'=>'Time until Clippy shows his face again', 'value' => '2000'},
        {'name' =>'thankyoumessage', 'description' =>'Thankyou message after downloading', 'ui_label'=>'Thankyou message after downloading', 'value' => 'Thanks for upgrading your browser! Look forward to a safer, faster web!'}
    ]
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    save({'answer' => @datastore['answer']})
  end
  
end
