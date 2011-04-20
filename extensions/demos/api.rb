module BeEF
module Extension
module Demos
  
  module RegisterHttpHandlers
    
    extend BeEF::API::Server::Handler
    
    def self.mount_handlers(beef_server)
      # mount the handler to support the demos
      dir = File.dirname(__FILE__)+'/html/'
      
      beef_server.mount('/demos/', true, WEBrick::HTTPServlet::FileHandler, dir)
    end
    
  end

end
end
end