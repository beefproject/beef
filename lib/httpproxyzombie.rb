require 'webrick/httpproxy'
require 'webrick/httputils'

module BeEF
  class HttpProxyZombie < HttpProxyBase

    attr_accessor :proxy_zombie_id

    def initialize
      @configuration = BeEF::Configuration.instance
      
      @config = {}
      @config[:BindAddress] = @configuration.get('http_proxy_bind_address')
      @config[:Port] = @configuration.get('http_proxy_bind_port')
      @config[:ServerName] = "BeEF " + @configuration.get('beef_version')
      @config[:ServerSoftware] =  "BeEF " + @configuration.get('beef_version')

      proxy_zombie_id = nil

      super
    end

    def service(req, res)
      
      # TODO implement which HB to target
      if false 
        return if proxy_zombie_id.nil? # check if zombie is set
        zombie = BeEF::Models::Zombie.get(proxy_zombie_id)
        return if not zombie # check if zombie is registered with beef
      else                     
        proxy_zombie_id = 1    
      end                      

      # blocking request
      res = HttpProxyZombieHandler::forward_request(proxy_zombie_id, req, res)

      # remove beef hook if it exists
      remove_hook(res)

    end
  end
end