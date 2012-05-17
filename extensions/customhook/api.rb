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
module Customhook
  
  module RegisterHttpHandlers
    
    BeEF::API::Registrar.instance.register(BeEF::Extension::Customhook::RegisterHttpHandlers, BeEF::API::Server, 'mount_handler')
    BeEF::API::Registrar.instance.register(BeEF::Extension::Customhook::RegisterHttpHandlers, BeEF::API::Server, 'pre_http_start')
    
    def self.mount_handler(beef_server)
      configuration = BeEF::Core::Configuration.instance
      beef_server.mount(configuration.get("beef.extension.customhook.customhook_path"), BeEF::Extension::Customhook::Handler.new)
    end

    def self.pre_http_start(beef_server)
      configuration = BeEF::Core::Configuration.instance
      print_success "Successfully mounted a custom hook point"
      print_more "Mount Point: #{configuration.get('beef.extension.customhook.customhook_path')}\nLoading iFrame: #{configuration.get('beef.extension.customhook.customhook_target')}\n"
    end
  end
end
end
end
