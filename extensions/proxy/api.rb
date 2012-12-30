#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
