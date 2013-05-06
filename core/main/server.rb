#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Remove Thin 'Server' response header
Thin.send :remove_const, :SERVER
Thin::SERVER = nil

module BeEF
  module Core

    class Server

      include Singleton

      # @note Grabs the version of beef the framework is deployed on
      VERSION = BeEF::Core::Configuration.instance.get('beef.version')

      attr_reader :root_dir, :url, :configuration, :command_urls, :mounts, :semaphore

      def initialize
        @configuration = BeEF::Core::Configuration.instance
        beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
        beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
        @url = "http://#{beef_host}:#{beef_port}"
        @root_dir = File.expand_path('../../../', __FILE__)
        @command_urls = {}
        @mounts = {}
        @rack_app
        @semaphore = Mutex.new
      end

      def to_h
        {
            'beef_version'  => VERSION,
            'beef_url'      => @url,
            'beef_root_dir' => @root_dir,
            'beef_host'     => @configuration.get('beef.http.host'),
            'beef_port'     => @configuration.get('beef.http.port'),
            'beef_public'   => @configuration.get('beef.http.public'),
            'beef_public_port' => @configuration.get('beef.http.public_port'),
            'beef_dns_host' => @configuration.get('beef.http.dns_host'),
            'beef_dns_port' => @configuration.get('beef.http.dns_port'),
            'beef_hook'     => @configuration.get('beef.http.hook_file'),
            'beef_proto'    => @configuration.get('beef.http.https.enable') == true ? "https" : "http",
            'client_debug'  => @configuration.get("beef.client.debug")
        }
      end

      # Mounts a handler, can either be a hard or soft mount
      # @param [String] url The url to mount
      # @param [Class] http_handler_class Class to call once mount is triggered
      # @param args Arguments to pass to the http handler class
      def mount(url, http_handler_class, args = nil)
        # argument type checking
        raise Exception::TypeError, '"url" needs to be a string' if not url.string?

        if args == nil
          @mounts[url] = http_handler_class
        else
          @mounts[url] = http_handler_class, *args
        end
        print_debug("Server: mounted handler '#{url}'")
      end

      # Unmounts handler
      # @param [String] url URL to unmount.
      def unmount(url)
        raise Exception::TypeError, '"url" needs to be a string' if not url.string?
        @mounts.delete(url)
      end

      # Reload the URL map (used by the NetworkStack AssetHandler to mount new URLs at runtime)
      def remap
        @rack_app.remap(@mounts)
      end

      # Prepares the BeEF http server.
      def prepare
        # Create http handler for the javascript hook file
        self.mount("#{@configuration.get("beef.http.hook_file")}", BeEF::Core::Handlers::HookedBrowsers.new)

        # Create handler for the initialization checks (Browser Details)
        self.mount("/init", BeEF::Core::Handlers::BrowserDetails)

        # Dynamically get the list of all the http handlers using the API and register them
        BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'mount_handler', self)

        # Rack mount points
        @rack_app = Rack::URLMap.new(@mounts)

        if not @http_server

          # Set the logging level of Thin to match the config 
          Thin::Logging.silent = true
          if @configuration.get('beef.http.debug') == true
            Thin::Logging.silent = false
            Thin::Logging.debug = true
          end

          # Create the BeEF http server
          @http_server = Thin::Server.new(
              @configuration.get('beef.http.host'),
              @configuration.get('beef.http.port'),
              @rack_app)

          if @configuration.get('beef.http.https.enable') == true
            @http_server.ssl = true
            @http_server.ssl_options = {:private_key_file => $root_dir + "/" + @configuration.get('beef.http.https.key'),
                                      :cert_chain_file => $root_dir + "/" + @configuration.get('beef.http.https.cert'),
                                      :verify_peer => false}
          end
        end
      end

      # Starts the BeEF http server
      def start
        begin
          @http_server.start # starts the web server
        rescue RuntimeError => e
          if e.message =~ /no acceptor/ # the port is in use
            print_error "Another process is already listening on port #{@configuration.get('beef.http.port')}."
            print_error "Is BeEF already running? Exiting..."
            exit 127
          else
            raise
          end
        end
      end

    end
  end
end
