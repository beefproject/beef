module BeEF
module Extension
module Proxy

  class HttpProxyZombie < BeEF::Extension::Proxy::HttpProxyBase

    HB = BeEF::Core::Models::HookedBrowser

    def initialize
      @configuration = BeEF::Core::Configuration.instance
      @config = {}
      @config[:BindAddress] = @configuration.get('beef.extension.proxy.address')
      @config[:Port] = @configuration.get('beef.extension.proxy.port')
      @config[:ServerName] = "BeEF " + @configuration.get('beef.version')
      @config[:ServerSoftware] =  "BeEF " + @configuration.get('beef.version')
      super
    end

    def service(req, res)
      proxy_browser = HB.first(:is_proxy => true)
      if(proxy_browser != nil)
        proxy_browser_id = proxy_browser.id.to_s
        #print_debug "[PROXY] Current proxy browser id is #" + proxy_browser_id
      else
        proxy_browser_id = 1
        print_debug "[PROXY] Proxy browser not set. Defaulting to browser id #1"
      end

      forwarder = BeEF::Extension::Proxy::Handlers::Zombie::Handler.new
      res = forwarder.forward_request(proxy_browser_id, req, res)
      res
      # remove beef hook if it exists
      #remove_hook(res)

    end
  end

end
end
end
