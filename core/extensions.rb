#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extensions
    # Returns configuration of all enabled extensions
    # @return [Array] an array of extension configuration hashes that are enabled
    def self.get_enabled
      BeEF::Core::Configuration.instance.get('beef.extension').select { |_k, v| v['enable'] == true }
    rescue StandardError => e
      print_error "Failed to get enabled extensions: #{e.message}"
      print_error e.backtrace
    end

    # Returns configuration of all loaded extensions
    # @return [Array] an array of extension configuration hashes that are loaded
    def self.get_loaded
      BeEF::Core::Configuration.instance.get('beef.extension').select { |_k, v| v['loaded'] == true }
    rescue StandardError => e
      print_error "Failed to get loaded extensions: #{e.message}"
      print_error e.backtrace
    end

    # Load all enabled extensions
    # @note API fire for post_load
    def self.load
      BeEF::Core::Configuration.instance.load_extensions_config
      get_enabled.each do |k, _v|
        BeEF::Extension.load k
      end
      # API post extension load
      BeEF::API::Registrar.instance.fire BeEF::API::Extensions, 'post_load'
    rescue StandardError => e
      print_error "Failed to load extensions: #{e.message}"
      print_error e.backtrace
    end
  end
end
