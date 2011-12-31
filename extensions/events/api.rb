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
module Events
  
  module RegisterHttpHandler

    # Register API calls
    BeEF::API::Registrar.instance.register(BeEF::Extension::Events::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')
    
    #
    # Mounts the http handlers for the events extension. We use that to retrieve stuff
    # like keystroke, mouse clicks and form submission.
    #
    def self.mount_handler(beef_server)
      beef_server.mount('/event', BeEF::Extension::Events::Handler)
    end
  end
end
end
end
