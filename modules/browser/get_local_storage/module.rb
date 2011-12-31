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
class Get_local_storage < BeEF::Core::Command
  
  # More info:
  #   http://dev.w3.org/html5/webstorage/
  #   http://diveintohtml5.org/storage.html
  #
  
  def post_execute
    content = {}
    content['localStorage'] = @datastore['localStorage']
    save content
  end
  
end
