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
module BeEF
module API
module Server
  #
  # All modules that extend the Handler API will be called during handler mounting,
  # dismounting, managing operations.
  #
  # You want to use that API if you are developing an extension that requires to create
  # a new http handler to receive responses.
  #
  #  Example:
  #
  #     module A
  #       extend BeEF::API::Server::Handler
  #     end
  #
  #
  # BeEF Core then calls all the Handler extension modules like this:
  #
  #   BeEF::API::Server::Handler.extended_in_modules.each do |mod|
  #     ...
  #   end
  #
  module Hook 

    API_PATHS = {
        'pre_hook_send' => :pre_hook_send
    }
    
    #
    # This method is being called as the hooked response is being built 
    #
    #  Example:
    #
    #     module A
    #       extend BeEF::API::Server::Hook
    #       
    #       def pre_hook_send()
    #         ...
    #       end
    #     end
    #
    def pre_hook_send(handler)

    end
    
  end
  
end
end
end
