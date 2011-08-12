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
module Proxy 
module API  

  module RegisterHttpHandler
    
    # use of the API
    extend BeEF::API::Server
    
    def self.pre_http_start(http_hook_server)
        proxy = BeEF::Extension::Proxy::HttpProxyZombie.instance
        proxy.start
        config = BeEF::Core::Configuration.instance
        print_success "HTTP Proxy: http://#{config.get('beef.extension.proxy.address')}:#{config.get('beef.extension.proxy.port')}"
    end

    def self.mount_handler(beef_server)
      beef_server.mount('/proxy', false, BeEF::Extension::Events::Handler)
    end
    
  end

end
end
end
end
