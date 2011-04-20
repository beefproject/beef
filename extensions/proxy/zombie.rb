module BeEF
module Extension
module Proxy

  class HttpProxyZombie < BeEF::Extension::Proxy::HttpProxyBase

    attr_accessor :proxy_zombie_id

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
      
      # TODO implement which HB to target
      if false 
        return if proxy_zombie_id.nil? # check if zombie is set
        zombie = BeEF::Core::Models::Zombie.get(proxy_zombie_id)
        return if not zombie # check if zombie is registered with beef
      else                     
        proxy_zombie_id = 1    
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
