module BeEF
module Extension
module Proxy 
module API  

  module RegisterHttpHandler
    
    # use of the API
    extend BeEF::API::Server::Handler
    
    def self.pre_http_start(http_hook_server)
        proxy = BeEF::Extension::Proxy::HttpProxyZombie.instance
        proxy.start
        config = BeEF::Core::Configuration.instance
        print_success "HTTP Proxy: http://#{config.get('beef.extension.proxy.address')}:#{config.get('beef.extension.proxy.port')}"
    end
    
  end

end
end
end
end
