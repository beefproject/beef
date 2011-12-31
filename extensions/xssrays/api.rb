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
module Xssrays
  
  module RegisterHttpHandler

    BeEF::API::Registrar.instance.register(BeEF::Extension::Xssrays::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')
    
    # We register the http handler for the requester.
    # This http handler will retrieve the http responses for all requests
    def self.mount_handler(beef_server)
      beef_server.mount('/xssrays', BeEF::Extension::Xssrays::Handler.new)
    end
    
  end


  module RegisterPreHookCallback

    BeEF::API::Registrar.instance.register(BeEF::Extension::Xssrays::RegisterPreHookCallback, BeEF::API::Server::Hook, 'pre_hook_send')

    # checks at every polling if there are new scans to be started
    def self.pre_hook_send(hooked_browser, body, params, request, response)
        if hooked_browser != nil
          xssrays = BeEF::Extension::Xssrays::API::Scan.new
          xssrays.start_scan(hooked_browser, body)
        end
    end

  end
  
end
end
end
