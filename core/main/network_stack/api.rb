#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module NetworkStack
  
  module RegisterHttpHandler

    # Register the http handler for the network stack
    # @param [Object] server HTTP server instance
    def self.mount_handler(server)
      # @note this mounts the dynamic handler
      server.mount('/dh', BeEF::Core::NetworkStack::Handlers::DynamicReconstruction.new)
    end
    
  end
  
    BeEF::API::Registrar.instance.register(BeEF::Core::NetworkStack::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')

end
end
end
