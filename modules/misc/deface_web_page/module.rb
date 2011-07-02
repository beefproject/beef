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
class Deface_web_page < BeEF::Core::Command

  #
  # Defines and set up the command module.
  #
  def initialize
    super({
      'Name' => 'Deface Web Page',
      'Description' => 'Overwrite the body of the page the victim is on with the "Deface Content" string',
      'Category' => 'Misc',
      'Author' => 'antisnatchor',
      'Data' => [
        { 'name' => 'deface_content', 'ui_label'=>'Deface Content', 'type' => 'textarea', 'value' =>'Defaced!', 'width' => '400px', 'height' => '100px' },
      ],
      'File' => __FILE__
    })

    set_target({
      'verified_status' =>  VERIFIED_USER_NOTIFY, 
      'browser_name' =>     ALL
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