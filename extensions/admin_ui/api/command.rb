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
module Extension
module AdminUI
module API
  
  module CommandExtension
    
    extend BeEF::API::Command
    
    include BeEF::Core::Constants::Browsers
    include BeEF::Core::Constants::CommandModule
    
    #
    # Get the browser detail from the database.
    #
    def get_browser_detail(key)
      bd = BeEF::Core::Models::BrowserDetails
      (print_error "@session_id is invalid";return) if not BeEF::Filters.is_valid_hook_session_id?(@session_id)
      bd.get(@session_id, key)
    end
  end
  
end
end
end
end
