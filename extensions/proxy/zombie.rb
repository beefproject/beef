module BeEF
module Extension
module Proxy

  class HttpProxyZombie < BeEF::Extension::Proxy::HttpProxyBase

    attr_accessor :proxy_zombie_id

    HB = BeEF::Core::Models::HookedBrowser

    def initialize
      @configuration = BeEF::Core::Configuration.instance
      
      @config = {}
      @config[:BindAddress] = @configuration.get('beef.extension.proxy.address')
      @config[:Port] = @configuration.get('beef.extension.proxy.port')
      @config[:ServerName] = "BeEF " + @configuration.get('beef.version')
      @config[:ServerSoftware] =  "BeEF " + @configuration.get('beef.version')

      proxy_zombie_id = nil
      super
    end

    def service(req, res)
      
       proxy_zombie = HB.first(:is_proxy => true)
      if(proxy_zombie != nil)
        proxy_zombie_id = proxy_zombie.id.to_s
      else
        proxy_zombie_id = 1
        print_debug("Defaulting proxy zombie to the first one in the DB")
      end

      # blocking request
      res = BeEF::Extension::Proxy::Handlers::Zombie::Handler.forward_request(proxy_zombie_id, req, res)

      # remove beef hook if it exists
      remove_hook(res)

    end
  end

end
end
end
