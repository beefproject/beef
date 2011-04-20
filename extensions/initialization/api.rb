module BeEF
module Extension
module Initialization
  
  module RegisterHttpHandler
    # use of the API right here
    extend BeEF::API::Server::Handler
    
    #
    # Register the http handler for the initialization script that retrieves
    # all the information about hooked browsers.
    #
    def self.mount_handlers(beef_server)
      beef_server.mount('/init', false, BeEF::Extension::Initialization::Handler)
    end
    
  end
  
end
end
end