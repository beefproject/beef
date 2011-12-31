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
class Test_return_long_string < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'repeat', 'description' => 'Times to repeat', 'ui_label' => 'Times to repeat', 'value' =>'1024'},
        {'name' => 'repeat_string', 'description' => 'Strings to repeat', 'ui_label' => 'String to repeat', 'value' =>'\u00AE'}
    ]
  end

  
  def post_execute
    content = {}
    content['Result String'] = @datastore['result_string']
    save content
  end

end
