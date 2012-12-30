#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Router

      module RegisterRouterHandler
        def self.mount_handler(server)
          server.mount('/', BeEF::Core::Router::Router.new)
        end
      end

      BeEF::API::Registrar.instance.register(BeEF::Core::Router::RegisterRouterHandler, BeEF::API::Server, 'mount_handler')

    end
  end
end
