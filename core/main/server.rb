#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module Core
  #
  # Class defining the BeEF http server.
  #
  #   Example:
  #
  #     server = BeEF::Core::Server.instance
  #     server.prepare
  #     server.start
  #     ...
  #     server.stop
  #
  class Server

    include Singleton
    
    # Grabs the version of beef the framework is deployed on
    VERSION = BeEF::Core::Configuration.instance.get('beef.version')

    attr_reader :root_dir, :url, :configuration, :command_urls, :mounts
    #
    # Constructor
    #
    def initialize
      @configuration = BeEF::Core::Configuration.instance
      beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
      @url = "http://#{beef_host}:#{@configuration.get("beef.http.port")}"
      @root_dir = File.expand_path('../../../', __FILE__)
      @command_urls = {}
      @mounts = {}
    end
    
    #
    # Returns all server variables in a hash. Useful for Erubis when
    # generating the javascript for the command modules and hooking.
    #
    def to_h
      {
        'beef_version' => VERSION,
        'beef_url' => @url,
        'beef_root_dir' => @root_dir,
        'beef_host' => BeEF::Core::Configuration.instance.get('beef.http.host'),
        'beef_port' => BeEF::Core::Configuration.instance.get('beef.http.port'),
        'beef_dns' => BeEF::Core::Configuration.instance.get('beef.http.dns'),
        'beef_hook' =>  BeEF::Core::Configuration.instance.get('beef.http.hook_file')
      }
    end
    
    #
    #
    #
    def get_command_url(command_path)
      # argument type checking
      raise Exception::TypeError, '"command_path" needs to be a string' if not command_path.string?
      
      if not @command_urls[command_path].nil?
        return @command_urls[command_path]
      else
        return command_path
      end
    end
    
    #
    # Starts the BeEF http server.
    #
    def prepare
      if not @http_server
        config = {}
        config[:BindAddress] = @configuration.get('beef.http.host')
        config[:Port] = @configuration.get('beef.http.port')
        config[:Logger] = WEBrick::Log.new($stdout, WEBrick::Log::ERROR)
        config[:ServerName] = "BeEF " + VERSION
        config[:ServerSoftware] =  "BeEF " + VERSION
        
        @http_server = WEBrick::HTTPServer.new(config)
        
        # Create http handler for the javascript hook file
        mount("#{@configuration.get("beef.http.hook_file")}", true, BeEF::Core::Handlers::HookedBrowsers)
        
        #
        # We dynamically get the list of all http handler using the API and register them
        #
        BeEF::API.fire(BeEF::API::Server::Handler, 'mount_handlers', self)
      end
    end
    
    #
    # Starts the BeEF http server
    #
    def start
      # we trap CTRL+C in the console and kill the server
      trap("INT") { BeEF::Core::Server.instance.stop }
      
      # starts the web server
      @http_server.start
    end
    
    #
    # Stops the BeEF http server.
    #
    def stop
      if @http_server
        # shuts down the server
        @http_server.shutdown
        
        # print goodbye message
        puts
        print_info 'BeEF server stopped'
      end
    end
    
    #
    # Restarts the BeEF http server.
    #
    def restart; stop; start; end
   
    # 
    # Mounts a handler, can either be a hard or soft mount
    #
    # @param: {String} the url to mount
    # @param: {Boolean} set to true for a hard mount, false for a soft mount.
    # @param: {Class} class to call once mount is triggered
    # @param: {Various} arguments to pass to the http handler class
    #
    def mount(url, hard, http_handler_class, args = nil)
      # argument type checking
      raise Exception::TypeError, '"url" needs to be a string' if not url.string?
      raise Exception::TypeError, '"hard" needs to be a boolean' if not hard.boolean?
      raise Exception::TypeError, '"http_handler_class" needs to be a boolean' if not http_handler_class.class?
      
      if hard
        if args == nil
          @http_server.mount url, http_handler_class
        else
          @http_server.mount url, http_handler_class, *args
        end
      else
        if args == nil
          mounts[url] = http_handler_class
        else
          mounts[url] = http_handler_class, *args
        end
      end
    end
    
    #
    # Unmounts handler
    #
    # @param: {String} url to mount.
    # @param: {Boolean} set to true for a hard mount, false for a soft mount.
    #
    def unmount(url, hard)
      # argument type checking
      raise Exception::TypeError, '"url" needs to be a string' if not url.string?
      raise Exception::TypeError, '"hard" needs to be a boolean' if not hard.boolean?
      
      if hard
        @http_server.umount(url)
      else
        mounts.delete(url)
      end
    end
    
    private
    @http_server
    
  end
  
end
end
