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
      proxy_browser = HB.first(:is_proxy => true)
      if(proxy_browser != nil)
        proxy_browser_id = proxy_browser.id.to_s
        print_debug "[PROXY] Current proxy browser id is #" + proxy_browser_id
      else
        proxy_zombie_id = 1
        print_debug "[PROXY] Proxy browser not set so defaulting to browser id #1"
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
