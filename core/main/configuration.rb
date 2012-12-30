#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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
      def self.instance()
        return @@instance
      end

      # Loads the default configuration system
      # @param [String] configuration_file Configuration file to be loaded, by default loads $root_dir/config.yaml
      def initialize(config)
        raise Exception::TypeError, '"config" needs to be a string' if not config.string?
        raise Exception::TypeError, 'Configuration yaml cannot be found' if not File.exist?(config)
        begin
          #open base config
          @config = self.load(config)
          # set default value if key? does not exist
          @config.default = nil
          @@config = config
        rescue Exception => e
          print_error "Fatal Error: cannot load configuration file"
          print_debug e
        end
        @@instance = self
      end

      # Loads yaml file
      # @param [String] file YAML file to be loaded
      # @return [Hash] YAML formatted hash
      def load(file)
        begin
          return nil if not File.exists?(file)
          raw = File.read(file)
          return YAML.load(raw)
        rescue Exception => e
          print_debug "Unable to load '#{file}' #{e}"
          return nil
        end
      end

      # Returns the value of a selected key in the configuration file.
      # @param [String] key Key of configuration item
      # @return [Hash|String] The resulting value stored against the 'key'
      def get(key)
        subkeys = key.split('.')
        lastkey = subkeys.pop
        subhash = subkeys.inject(@config) do |hash, k|
          hash[k]
        end
        return (subhash != nil and subhash.has_key?(lastkey)) ? subhash[lastkey] : nil
      end

      # Sets the give key value pair to the config instance
      # @param [String] key The configuration key
      # @param value The value to be stored against the 'key'
      # @return [Boolean] If the store procedure was successful
      def set(key, value)
        subkeys = key.split('.').reverse
        return false if subkeys.length == 0
        hash = {subkeys.shift.to_s => value}
        subkeys.each{|v|
          hash = {v.to_s => hash}
        }
        @config = @config.deep_merge(hash)
        return true
      end

      # Clears the given key hash
      # @param [String] key Configuration key to be cleared
      # @return [Boolean] If the configuration key was cleared
      def clear(key)
        subkeys = key.split('.')
        return false if subkeys.length == 0
        lastkey = subkeys.pop
        hash = @config
        subkeys.each{|v|
          hash = hash[v]
        }
        return (hash.delete(lastkey) == nil) ? false : true
      end

      # Load extensions configurations
      def load_extensions_config
        self.set('beef.extension', {})
        Dir.glob("#{$root_dir}/extensions/*/config.yaml") do | cf |
          y = self.load(cf)
          if y != nil
            y['beef']['extension'][y['beef']['extension'].keys.first]['path'] = cf.gsub(/config\.yaml/, '').gsub(/#{$root_dir}\//, '')
            @config = y.deep_merge(@config)
          else
            print_error "Unable to load extension configuration '#{cf}'"
          end
        end
      end

      # Load module configurations
      def load_modules_config
        self.set('beef.module', {})
        # support nested sub-categories, like browser/hooked_domain/ajax_fingerprint
        module_configs = File.join("#{$root_dir}/modules/**", "config.yaml")
        Dir.glob(module_configs) do | cf |
          y = self.load(cf)
          if y != nil
            y['beef']['module'][y['beef']['module'].keys.first]['path'] = cf.gsub(/config\.yaml/, '').gsub(/#{$root_dir}\//, '')
            @config = y.deep_merge(@config)
            # API call for post module config load
            BeEF::API::Registrar.instance.fire(BeEF::API::Configuration, 'module_configuration_load', y['beef']['module'].keys.first)
          else
            print_error "Unable to load module configuration '#{cf}'"
          end
        end
      end

    end
  end
end
