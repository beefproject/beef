module BeEF
module Extension
module Events
  
  module RegisterHttpHandler
    # use of the API right here
    extend BeEF::API::Server::Handler
    
    #
    # Mounts the http handlers for the events extension. We use that to retrieve stuff
    # like keystroke, mouse clicks and form submission.
    #
    def self.mount_handlers(beef_server)
      beef_server.mount('/event', false, BeEF::Extension::Events::Handler)
    end
    
  end
  
end
end
end