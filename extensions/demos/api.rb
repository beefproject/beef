#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Demos
      module RegisterHttpHandlers
        BeEF::API::Registrar.instance.register(BeEF::Extension::Demos::RegisterHttpHandlers, BeEF::API::Server, 'mount_handler')

        #
        # Mounts the handlers for the demos pages
        #
        # @param beef_server [BeEF::Core::Server] HTTP server instance
        #
        def self.mount_handler(beef_server)
          beef_server.mount('/demos', BeEF::Extension::Demos::Handler.new)
        end
      end
    end
  end
end
