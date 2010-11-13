module BeEF
module Requester
  
  # Setting up the proxy server for the Requester
  class ProxyServer
    
    include Singleton
    
    def initialize
      @config = {
        :Port => 8080,
        :BindAddress => '127.0.0.1',
        :Logger => WEBrick::Log.new($stdout, WEBrick::Log::ERROR),
        :ServerType => Thread,
        :RequestCallback => BeEF::Requester::ProxyHttpHandler.new
      }
      
      @server = WEBrick::HTTPProxyServer.new @config
      
      trap("INT"){@server.shutdown}
    end
    
    def start
      @server.start
    end
    
  end
  
  # The http handler that receives requests
  class ProxyHttpHandler
    def call(req, res)
      #puts req.request_line, req.raw_header
    end
  end
  
end
end