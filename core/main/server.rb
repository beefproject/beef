#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
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
      attr_reader :root_dir, :url, :configuration, :command_urls, :mounts, :semaphore

      def initialize
        @configuration = BeEF::Core::Configuration.instance
        @url = @configuration.beef_url_str
        @root_dir = File.expand_path('../../../', __dir__)
        @command_urls = {}
        @mounts = {}
        @rack_app
        @semaphore = Mutex.new
      end

      def to_h
        {
          'beef_version' => @configuration.get('beef_version'),
          'beef_url' => @url,
          'beef_root_dir' => @root_dir,
          'beef_host' => @configuration.beef_host,
          'beef_port' => @configuration.beef_port,
          'beef_public' => @configuration.public_host,
          'beef_public_port' => @configuration.public_port,
          'beef_hook' => @configuration.get('beef.http.hook_file'),
          'beef_proto' => @configuration.beef_proto,
          'client_debug' => @configuration.get('beef.client_debug')
        }
      end

      #
      # Mounts a handler, can either be a hard or soft mount
      #
      # @param [String] url The url to mount
      # @param [Class] http_handler_class Class to call once mount is triggered
      # @param args Arguments to pass to the http handler class
      #
      def mount(url, http_handler_class, args = nil)
        # argument type checking
        raise TypeError, '"url" needs to be a string' unless url.is_a?(String)

        @mounts[url] = if args.nil?
                         http_handler_class
                       else
                         [http_handler_class, *args]
                       end
        print_debug "Server: mounted handler '#{url}'"
      end

      #
      # Unmounts handler
      #
      # @param [String] url URL to unmount.
      #
      def unmount(url)
        raise TypeError, '"url" needs to be a string' unless url.is_a?(String)

        @mounts.delete url
      end

      #
      # Reload the URL map (used by the NetworkStack AssetHandler to mount new URLs at runtime)
      #
      def remap
        @rack_app.remap @mounts
      end

      #
      # Prepares the BeEF http server.
      #
      def prepare
        # Create http handler for the javascript hook file
        mount(@configuration.get('beef.http.hook_file').to_s, BeEF::Core::Handlers::HookedBrowsers.new)

        # Create handler for the initialization checks (Browser Details)
        mount('/init', BeEF::Core::Handlers::BrowserDetails)

        # Dynamically get the list of all the http handlers using the API and register them
        BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'mount_handler', self)

        # Rack mount points
        @rack_app = Rack::URLMap.new(@mounts)

        return if @http_server

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
          @rack_app
        )

        # Configure SSL/TLS
        return unless @configuration.get('beef.http.https.enable') == true

        openssl_version = OpenSSL::OPENSSL_VERSION
        if openssl_version =~ / 1\.0\.1([a-f])? /
          print_warning "Warning: #{openssl_version} is vulnerable to Heartbleed (CVE-2014-0160)."
          print_more 'Upgrade OpenSSL to version 1.0.1g or newer.'
        end

        cert_key = @configuration.get 'beef.http.https.key'
        cert_key = File.expand_path cert_key, $root_dir unless cert_key.start_with? '/'
        unless File.exist? cert_key
          print_error "Error: #{cert_key} does not exist"
          exit 1
        end

        cert = @configuration.get 'beef.http.https.cert'
        cert = File.expand_path cert, $root_dir unless cert.start_with? '/'
        unless File.exist? cert
          print_error "Error: #{cert} does not exist"
          exit 1
        end

        @http_server.ssl = true
        @http_server.ssl_options = {
          private_key_file: cert_key,
          cert_chain_file: cert,
          verify_peer: false
        }

        if Digest::SHA256.hexdigest(File.read(cert)).eql?('978f761fc30cbd174eab0c6ffd2d235849260c0589a99262f136669224c8d82a') ||
           Digest::SHA256.hexdigest(File.read(cert_key)).eql?('446214bb608caf9e21dd105ce3d4ea65a3f32949906f3eb25a2c622a68623122')
          print_warning 'Warning: Default SSL cert/key in use.'
          print_more 'Use the generate-certificate utility to generate a new certificate.'
        end
      rescue StandardError => e
        print_error "Failed to prepare HTTP server: #{e.message}"
        print_error e.backtrace
        exit 1
      end

      #
      # Starts the BeEF http server
      #
      def start
        @http_server.start do
          use OTR::ActiveRecord::ConnectionManagement
        end
      rescue RuntimeError => e
        # port is in use
        raise unless e.message.include? 'no acceptor'

        print_error "Another process is already listening on port #{@configuration.get('beef.http.port')}, or you're trying to bind BeEF to an invalid IP."
        print_error 'Is BeEF already running? Exiting...'
        exit 127
      end
    end
  end
end
