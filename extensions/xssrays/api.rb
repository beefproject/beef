#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Xssrays
  
  module RegisterHttpHandler

    BeEF::API::Registrar.instance.register(BeEF::Extension::Xssrays::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')
    
    # We register the http handler for the requester.
    # This http handler will retrieve the http responses for all requests
    def self.mount_handler(beef_server)
      beef_server.mount('/xssrays', BeEF::Extension::Xssrays::Handler.new)
    end
    
  end


  module RegisterPreHookCallback

    BeEF::API::Registrar.instance.register(BeEF::Extension::Xssrays::RegisterPreHookCallback, BeEF::API::Server::Hook, 'pre_hook_send')

    # checks at every polling if there are new scans to be started
    def self.pre_hook_send(hooked_browser, body, params, request, response)
        if hooked_browser != nil
          xssrays = BeEF::Extension::Xssrays::API::Scan.new
          xssrays.start_scan(hooked_browser, body)
        end
    end

  end
  
end
end
end
