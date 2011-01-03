module BeEF
  
  #
  # Class defining the BeEF http server.
  #
  class HttpHookServer
    
    # call BeEF::Server.instance
    include Singleton
    
    VERSION = BeEF::Configuration.instance.get('beef_version')
    
    attr_reader :root_dir, :url, :configuration, :command_urls
    
    def initialize
      @configuration = BeEF::Configuration.instance
      beef_host = @configuration.get("http_public") || @configuration.get("http_host")
      @url = "http://#{beef_host}:#{@configuration.get("http_port")}"
      @root_dir = File.expand_path('../../../', __FILE__)
      @command_urls = {}
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
        'beef_host' => BeEF::Configuration.instance.get('http_host'),
        'beef_port' => BeEF::Configuration.instance.get('http_port'),
        'beef_dns' => BeEF::Configuration.instance.get('http_dns'),
        'beef_hook' =>  BeEF::Configuration.instance.get('hook_file')
      }
    end
    
    #
    #
    #
    def register_command_url(command_path, uri)
    end
    
    #
    #
    #
    def get_command_url(command_path)
      if not @command_urls[command_path].nil? then return @command_urls[command_path]; else return command_path; end
    end
    
    #
    # Starts the BeEF http server.
    #
    def start
      if not @http_server
        config = {}
        config[:BindAddress] = @configuration.get('http_host')
        config[:Port] = @configuration.get('http_port')
        config[:Logger] = WEBrick::Log.new($stdout, WEBrick::Log::ERROR)
        config[:ServerName] = "BeEF " + VERSION
        config[:ServerSoftware] =  "BeEF " + VERSION

        @http_server = WEBrick::HTTPServer.new(config)

        # registers the ui pages
        Dir["#{$root_dir}/lib/ui/**/*.rb"].each { |http_module|
          require http_module
          mod_name = File.basename http_module, '.rb'
          @http_server.mount "/ui/#{mod_name}", BeEF::HttpHandler, mod_name
        }
        
        # registers the command module pages
        Dir["#{root_dir}/modules/commands/**/*.rb"].each { |command|
          command_class = (File.basename command, '.rb').capitalize
          command_file = (File.basename command, '.rb')+'.js'
          
          #TODO: implement URL obfuscation at start up.
          @http_server.mount "/command/#{command_file}", BeEF::CommandHandler, command_class
        }
        
        # registers the hook page
        @http_server.mount "#{@configuration.get("hook_file")}", BeEF::ZombieHandler
        
        # registers the requester page
        @http_server.mount '/requester', BeEF::RequesterHandler
        
        # registers the event handler
        @http_server.mount '/event', BeEF::EventHandler
        
        # registers the init page
        @http_server.mount '/init', BeEF::InitHandler
        
        # registers the event handler
        @http_server.mount '/event', BeEF::EventHandler
        
        @http_server.mount '/ui/public', BeEF::PublicHandler, "#{root_dir}/public"
        @http_server.mount '/favicon.ico', WEBrick::HTTPServlet::FileHandler, "#{root_dir}#{@configuration.get("favicon_dir")}/#{@configuration.get("favicon_file_name")}"
        @http_server.mount '/demos/', WEBrick::HTTPServlet::FileHandler, "#{root_dir}/demos/"
        
        trap("INT") { BeEF::HttpHookServer.instance.stop }
        
        @http_server.start
      end
    end
    
    #
    # Stops the BeEF http server.
    #
    def stop;
      if @http_server
        @http_server.shutdown
        puts ' --[ BeEF server stopped'
      end
    end
    
    #
    # Restarts the BeEF http server.
    #
    def restart; stop; start; end
    
    
    private
    @http_server
    
  end
  
end
