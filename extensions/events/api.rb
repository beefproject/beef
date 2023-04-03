#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Events
      # Mounts the handler for processing browser events.
      #
      # @param beef_server [BeEF::Core::Server] HTTP server instance
      module RegisterHttpHandler
        BeEF::API::Registrar.instance.register(BeEF::Extension::Events::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')

        def self.mount_handler(beef_server)
          beef_server.mount('/event', BeEF::Extension::Events::Handler)
        end
      end
    end
  end
end
