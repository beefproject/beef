#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    class Configuration
      attr_accessor :config

      # antisnatchor: still a singleton, but implemented by hand because we want to have only one instance
      # of the Configuration object while having the possibility to specify a parameter to the constructor.
      # This is  why we don't use anymore the default Ruby implementation -> include Singleton
      def self.instance
        @@instance
      end

      # Loads the default configuration system
      # @param [String] configuration_file Configuration file to be loaded,
      #        by default loads $root_dir/config.yaml
      def initialize(config)
        raise TypeError, "'config' needs to be a string" unless config.is_a?(String)
        raise TypeError, "Configuration file '#{config}' cannot be found" unless File.exist? config

        begin
          # open base config
          @config = load(config)
          # set default value if key? does not exist
          @config.default = nil
          @@config = config
        rescue StandardError => e
          print_error "Fatal Error: cannot load configuration file '#{config}' : #{e.message}"
          print_more e.backtrace
          exit(1)
        end

        @@instance = self
      end

      # Loads yaml file
      # @param [String] file YAML file to be loaded
      # @return [Hash] YAML formatted hash
      def load(file)
        return nil unless File.exist?(file)
        YAML.safe_load(File.binread(file))
      end

      #
      # @note balidate the configuration file
      #
      def validate
        if @config.empty?
          print_error 'Configuration file is empty'
          return
        end

        if @config['beef'].nil?
          print_error "Configuration file is malformed: 'beef' is nil"
          return
        end

        if @config['beef']['credentials'].nil?
          print_error "Configuration file is malformed: 'beef.credentials' is nil"
          return
        end

        if @config['beef']['http'].nil?
          print_error "Configuration file is malformed: 'beef.http' is nil"
          return
        end

        return unless validate_public_config_variable?(@config)

        if @config['beef']['http']['public_port']
          print_error 'Config path beef.http.public_port is deprecated.'
          print_error 'Please use the new format for public variables found'
          print_error 'https://github.com/beefproject/beef/wiki/Configuration#web-server-configuration'
          return
        end

        true
      end

      #
      # Returns the configuration value for the http server host
      # If nothing is set it should default to 0.0.0.0 (all interfaces)
      def local_host
        get('beef.http.host') || '0.0.0.0'
      end

      #
      # Returns the configuration value for the http server port
      # If nothing is set it should default to 3000
      def local_port
        get('beef.http.port') || '3000'
      end

      #
      # Return the local protocol
      # if nothing is set default to http
      def local_proto
        local_https_enabled ? 'https' : 'http'
      end

      #
      # Returns the configuration value for the local https enabled
      # If nothing is set it should default to false
      def local_https_enabled
        get('beef.http.https.enable') || false
      end

      #
      # Returns the configuration value for the http server host
      def public_host
        get('beef.http.public.host')
      end

      #
      # Returns the beef host which is used by external resources
      # e.g. hooked browsers
      def beef_host
        public_host || local_host
      end

      #
      # Returns the beef port which is used by external resource
      # e.g. hooked browsers
      def beef_port
        public_port || local_port
      end

      def public_enabled?
        !get('beef.http.public.host').nil?
      end

      #
      # Returns the beef protocol that is used by external resources
      # e.g. hooked browsers
      def beef_proto
        if public_enabled? && public_https_enabled?
          'https'
        elsif public_enabled? && !public_https_enabled?
          'http'
        elsif !public_enabled?
          local_proto
        end
      end

      #
      # Returns the beef scheme://host:port for external resources
      # e.g. hooked browsers
      def beef_url_str
        "#{beef_proto}://#{beef_host}:#{beef_port}"
      end

      # Returns the hool path value stored in the config file
      #
      # @return [String] hook file path
      def hook_file_path
        get('beef.http.hook_file') || '/hook.js'
      end

      # Returns the url to the hook file
      #
      # @return [String] the url string
      def hook_url
        "#{beef_url_str}#{hook_file_path}"
      end

      # Returns the configuration value for the http server port
      # If nothing is set it should default to 3000
      def public_port
        return get('beef.http.public.port') unless get('beef.http.public.port').nil?

        return '443' if public_https_enabled?
        return '80' unless public_host.nil?

        nil
      end

      #
      # Returns the configuration value for the local https enabled
      # If nothing is set it should default to false
      def public_https_enabled?
        get('beef.http.public.https') || false
      end

      #
      # Returns the value of a selected key in the configuration file.
      # @param [String] key Key of configuration item
      # @return [Hash|String] The resulting value stored against the 'key'
      #
      def get(key)
        subkeys = key.split('.')
        lastkey = subkeys.pop
        subhash = subkeys.inject(@config) do |hash, k|
          hash[k]
        end
        return nil if subhash.nil?

        subhash.key?(lastkey) ? subhash[lastkey] : nil
      end

      #
      # Sets the give key value pair to the config instance
      # @param [String] key The configuration key
      # @param value The value to be stored against the 'key'
      # @return [Boolean] If the store procedure was successful
      #
      def set(key, value)
        subkeys = key.split('.').reverse
        return false if subkeys.empty?

        hash = { subkeys.shift.to_s => value }
        subkeys.each { |v| hash = { v.to_s => hash } }
        @config = @config.deep_merge hash
        true
      end

      #
      # Clears the given key hash
      # @param [String] key Configuration key to be cleared
      # @return [Boolean] If the configuration key was cleared
      #
      def clear(key)
        subkeys = key.split('.')
        return false if subkeys.empty?

        lastkey = subkeys.pop
        hash = @config
        subkeys.each { |v| hash = hash[v] }
        hash.delete(lastkey).nil? ? false : true
      end

      #
      # Load extensions configurations
      #
      def load_extensions_config
        set('beef.extension', {})
        Dir.glob("#{$root_dir}/extensions/*/config.yaml") do |cf|
          y = load(cf)
          if y.nil?
            print_error "Unable to load extension configuration '#{cf}'"
            next
          end

          y['beef']['extension'][y['beef']['extension'].keys.first]['path'] = cf.gsub(/config\.yaml/, '').gsub(%r{#{$root_dir}/}, '')
          @config = y.deep_merge(@config)
        end
      end

      #
      # Load module configurations
      #
      def load_modules_config
        set('beef.module', {})
        # support nested sub-categories, like browser/hooked_domain/ajax_fingerprint
        module_configs = File.join("#{$root_dir}/modules/**", 'config.yaml')
        Dir.glob(module_configs) do |cf|
          y = load(cf)
          if y.nil?
            print_error "Unable to load module configuration '#{cf}'"
            next
          end

          y['beef']['module'][y['beef']['module'].keys.first]['path'] = cf.gsub('config.yaml', '').gsub(%r{#{$root_dir}/}, '')
          @config = y.deep_merge @config
          # API call for post module config load
          BeEF::API::Registrar.instance.fire(
            BeEF::API::Configuration,
            'module_configuration_load',
            y['beef']['module'].keys.first
          )
        end
      end

      private

      def validate_public_config_variable?(config)
        return true if config['beef']['http']['public'].is_a?(Hash) ||
                       config['beef']['http']['public'].is_a?(NilClass)

        print_error 'Config path beef.http.public is deprecated.'
        print_error 'Please use the new format for public variables found'
        print_error 'https://github.com/beefproject/beef/wiki/Configuration#web-server-configuration'
        false
      end
    end
  end
end
