#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extensions

    # Returns configuration of all enabled extensions
    # @return [Array] an array of extension configuration hashes that are enabled
    def self.get_enabled
      return BeEF::Core::Configuration.instance.get('beef.extension').select { |k,v| v['enable'] == true }
    end

    # Returns configuration of all loaded extensions
    # @return [Array] an array of extension configuration hashes that are loaded
    def self.get_loaded
      return BeEF::Core::Configuration.instance.get('beef.extension').select {|k,v| v['loaded'] == true }
    end

    # Load all enabled extensions
    # @note API fire for post_load
    def self.load
      BeEF::Core::Configuration.instance.load_extensions_config
      self.get_enabled.each { |k,v|
        BeEF::Extension.load(k)
      }
      # API post extension load
      BeEF::API::Registrar.instance.fire(BeEF::API::Extensions, 'post_load')
    end

  end
end

