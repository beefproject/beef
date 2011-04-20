module BeEF
module Core
module NetworkStack
  
  module RegisterHttpHandler
    # use of the API right here
    extend BeEF::API::Server::Handler
    
    #
    # Register the http handler for the network stack
    #
    def self.mount_handlers(beef_server)
      #dynamic handler
      beef_server.mount('/dh', true, BeEF::Core::NetworkStack::Handlers::DynamicReconstruction)
    end
    
  end
  
end
end
end