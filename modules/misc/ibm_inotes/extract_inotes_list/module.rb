#
#   Copyright (c) 2006-2015 Wade Alcorn wade@bindshell.net
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
class Extract_inotes_list < BeEF::Core::Command
 def self.options
    return [
      {'type' => 'label', 'html' => 'Provide date boundaries to retrieve a list of Notes:' },
      {'type' => 'textfield', 'name' => 'startdate', 'ui_label' => 'startdate yyyymmdd', 'value' => '20140101'},
      {'type' => 'textfield', 'name' => 'enddate', 'ui_label' => 'enddate yyyymmdd', 'value' => '20500101'},
      {'type' => 'textfield', 'name' => 'count', 'ui_label' => 'number of items returned', 'value' => '-1'},
    ]
  end 
  def post_execute
    save({'result' => @datastore['result']})
  end

end
