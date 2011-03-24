module BeEF
  
  #
  # Class defining the BeEF http server.
  #
  class HttpHookServer
    
    # call BeEF::Server.instance
    include Singleton
    
    VERSION = BeEF::Configuration.instance.get('beef_version')
    
    attr_reader :root_dir, :url, :configuration, :command_urls, :mounts
    
    def initialize
      @configuration = BeEF::Configuration.instance
      beef_host = @configuration.get("http_public") || @configuration.get("http_host")
      @url = "http://#{beef_host}:#{@configuration.get("http_port")}"
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
        @asset_handler = BeEF::AssetHandler.instance

        # registers the ui pages
        Dir["#{$root_dir}/lib/ui/**/*.rb"].each { |http_module|
          require http_module
          mod_name = File.basename http_module, '.rb'
          mount("/ui/#{mod_name}", true, BeEF::HttpHandler, mod_name)
        }
        
        # registers the hook page
        mount("#{@configuration.get("hook_file")}", true, BeEF::ZombieHandler)
        mount('/ui/public', true, BeEF::PublicHandler, "#{root_dir}/public")
        mount('/favicon.ico', true, WEBrick::HTTPServlet::FileHandler, "#{root_dir}#{@configuration.get("favicon_dir")}/#{@configuration.get("favicon_file_name")}")
        mount('/demos/', true, WEBrick::HTTPServlet::FileHandler, "#{root_dir}/demos/")

        #dynamic handler
        mount('/dh', true, BeEF::DynamicHandler)

        #register mounts handled by dynamic handler
        mount('/init', false, BeEF::InitHandler)
        mount('/event', false, BeEF::EventHandler)
        mount('/requester', false, BeEF::RequesterHandler)

        # registers the command module pages
        Dir["#{root_dir}/modules/commands/**/*.rb"].each { |command|
          command_class = (File.basename command, '.rb').capitalize
          command_file = (File.basename command, '.rb')+'.js'
          mount("/command/#{command_file}", false, BeEF::CommandHandler, command_class)
        }

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
   
    # 
    # Mounts a handler, can either be a hard or soft mount (soft mounts are handled by the command handler
    #
    def mount(url, hard, c, args = nil)
       if hard
           if args == nil
               @http_server.mount url, c
            else
               @http_server.mount url, c, *args
            end
        else
            if args == nil
                mounts[url] = c
            else
                mounts[url] = c, *args
            end
        end
    end

    #
    # Unmounts handler
    #
    def unmount(url, hard)
        if hard
            @http_server.umount(url)
        else
            mounts.delete(url)
        end
    end
    
    private
    @http_server
    @asset_handler
    
  end
  
end
