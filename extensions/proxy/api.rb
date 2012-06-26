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
    module Proxy
      module API

        module RegisterHttpHandler

          BeEF::API::Registrar.instance.register(BeEF::Extension::Proxy::API::RegisterHttpHandler, BeEF::API::Server, 'pre_http_start')
          BeEF::API::Registrar.instance.register(BeEF::Extension::Proxy::API::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')

          def self.pre_http_start(http_hook_server)
            config = BeEF::Core::Configuration.instance
            Thread.new{
              http_hook_server.semaphore.synchronize{
                BeEF::Extension::Proxy::Proxy.new
              }
            }
            print_info "HTTP Proxy: http://#{config.get('beef.extension.proxy.address')}:#{config.get('beef.extension.proxy.port')}"
          end

          def self.mount_handler(beef_server)
            beef_server.mount('/proxy', BeEF::Extension::Requester::Handler)
          end

        end


      end
    end
  end
end
