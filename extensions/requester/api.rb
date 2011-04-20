module BeEF
module Extension
module Requester
  
  module RegisterHttpHandler
    
    # use of the API
    extend BeEF::API::Server::Handler
    
    # We register the http handler for the requester.
    # This http handler will retrieve the http responses for all requests
    def self.mount_handlers(beef_server)
      beef_server.mount('/requester', false, BeEF::Extension::Requester::Handler)
    end
    
  end

  module RegisterPreHookCallback

    extend BeEF::API::Server::Hook

    def self.pre_hook_send(hooked_browser, body, params, request, response)
        dhook = BeEF::Extension::Requester::API::Hook.new 
        dhook.requester_run(hooked_browser, body)
    end

  end
  
end
end
end
