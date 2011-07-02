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
module Extension
module Requester
  
  module RegisterHttpHandler
    
    # use of the API
    extend BeEF::API::Server::Handler
    
    # We register the http handler for the requester.
    # This http handler will retrieve the http responses for all requests
    def self.mount_handlers(beef_server)
      beef_server.mount('/requester', false, BeEF::Extension::Requester::Handler)
    end
    
  end

  module RegisterPreHookCallback

    extend BeEF::API::Server::Hook

    def self.pre_hook_send(hooked_browser, body, params, request, response)
        dhook = BeEF::Extension::Requester::API::Hook.new
        dhook.requester_run(hooked_browser, body)
    end

  end
  
end
end
end
