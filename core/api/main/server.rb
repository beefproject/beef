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

    API_PATHS = {
        'mount_handler' => :mount_handler,
        'pre_http_start' => :pre_http_start
    }
    
    def pre_http_start(http_hook_server); end
    
    def mount_handler(server); end
    
    def self.mount(url, hard, http_handler_class, args = nil)
      BeEF::Core::Server.instance.mount(url, hard, http_handler_class, *args)
    end

    def self.unmount(url, hard)
        BeEF::Core::Server.instance.unmount(url, hard)
    end

  
end
end
end
