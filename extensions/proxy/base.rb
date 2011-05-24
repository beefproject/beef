module BeEF
module Extension
module Proxy

  class HttpProxyBase < WEBrick::HTTPProxyServer

    # call BeEF::HttpProxyZombie.instance
    include Singleton

    attr_reader :config
    
    def initialize
      @configuration = BeEF::Core::Configuration.instance
      @config[:Logger] = WEBrick::Log.new($stdout, WEBrick::Log::ERROR)
      @config[:ServerType] = Thread
      super(@config)
    end

    # remove beef hook if it exists
    def remove_hook(res)
      print_debug "[PROXY] Removing beef hook from page if present"
      res.body.gsub!(%r'<script.*?http.*?exploit.js.*?</script>', '')
    end
  end

end
end
end
