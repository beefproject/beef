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
module BeEF
module API
module Server
  module Hook 

    # @note Defined API Paths
    API_PATHS = {
        'pre_hook_send' => :pre_hook_send
    }
    
    # Fires just before the hook is sent to the hooked browser
    # @param [Class] handler the associated handler Class
    def pre_hook_send(handler); end
    
  end
  
end
end
end
