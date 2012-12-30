#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Requester
  
  module RegisterHttpHandler
    
    BeEF::API::Registrar.instance.register(BeEF::Extension::Requester::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')
    
    # We register the http handler for the requester.
    # This http handler will retrieve the http responses for all requests
    def self.mount_handler(beef_server)
      beef_server.mount('/requester', BeEF::Extension::Requester::Handler)
    end
    
  end

  module RegisterPreHookCallback

    BeEF::API::Registrar.instance.register(BeEF::Extension::Requester::RegisterPreHookCallback, BeEF::API::Server::Hook, 'pre_hook_send')

    def self.pre_hook_send(hooked_browser, body, params, request, response)
        dhook = BeEF::Extension::Requester::API::Hook.new
        dhook.requester_run(hooked_browser, body)
    end

  end
  
end
end
end
