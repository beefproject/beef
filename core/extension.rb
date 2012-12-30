#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension

    # Checks to see if extension is set inside the configuration
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension exists in BeEF's configuration
    def self.is_present(ext)
      return BeEF::Core::Configuration.instance.get('beef.extension').has_key?(ext.to_s)
    end

    # Checks to see if extension is enabled in configuration
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension is enabled 
    def self.is_enabled(ext)
      return (self.is_present(ext) and BeEF::Core::Configuration.instance.get('beef.extension.'+ext.to_s+'.enable') == true)
    end

    # Checks to see if extension has been loaded
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension is loaded 
    def self.is_loaded(ext)
      return (self.is_enabled(ext) and BeEF::Core::Configuration.instance.get('beef.extension.'+ext.to_s+'.loaded') == true)
    end

    # Loads an extension 
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension loaded successfully
    # @todo Wrap the require() statement in a try catch block to allow BeEF to fail gracefully if there is a problem with that extension - Issue #480
    def self.load(ext)
      if File.exists?('extensions/'+ext+'/extension.rb')
        require 'extensions/'+ext+'/extension.rb'
        print_debug "Loaded extension: '#{ext}'"
        BeEF::Core::Configuration.instance.set('beef.extension.'+ext+'.loaded', true)
        return true
      end
      print_error "Unable to load extension '#{ext}'"
      return false
    end
  end
end
