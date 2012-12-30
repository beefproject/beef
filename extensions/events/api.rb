#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Events
  
  module RegisterHttpHandler

    # Register API calls
    BeEF::API::Registrar.instance.register(BeEF::Extension::Events::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')
    
    #
    # Mounts the http handlers for the events extension. We use that to retrieve stuff
    # like keystroke, mouse clicks and form submission.
    #
    def self.mount_handler(beef_server)
      beef_server.mount('/event', BeEF::Extension::Events::Handler)
    end
  end
end
end
end
