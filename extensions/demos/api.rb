#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Demos
  
  module RegisterHttpHandlers
    
    BeEF::API::Registrar.instance.register(BeEF::Extension::Demos::RegisterHttpHandlers, BeEF::API::Server, 'mount_handler')
    
    def self.mount_handler(beef_server)
      # mount the handler to support the demos
      dir = File.dirname(__FILE__)+'/html/'
      beef_server.mount('/demos/', Rack::File.new(dir))
    end
  end
end
end
end
