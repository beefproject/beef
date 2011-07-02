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
class Insecure_url_skype < BeEF::Core::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Insecure URL Handling - Skype Call',
      'Description' => 'This module will force the browser to attempt a skype call. It will exploit the insecure handling of URL schemes<br>
      <br>
      The protocol handler used will be: skype',
      'Category' => 'Host',
      'Author' => 'xntrik, Nitesh Dhanjani',
      'Data' => [
        { 'name' => 'tel_num', 'ui_label'=>'Number', 'value' =>'5551234', 'width' => '200px' }
      ],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_WORKING,
      'browser_name' =>     S
    })
    
    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => C
    })
    
    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => FF
    })

    set_target({
      'verified_status' => VERIFIED_USER_NOTIFY,
      'browser_name' => O
    })

    use 'beef.dom'
    use_template!
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end