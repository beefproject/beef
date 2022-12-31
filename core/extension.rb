#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    # Checks to see if extension is set inside the configuration
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension exists in BeEF's configuration
    def self.is_present(ext)
      BeEF::Core::Configuration.instance.get('beef.extension').key? ext.to_s
    end

    # Checks to see if extension is enabled in configuration
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension is enabled
    def self.is_enabled(ext)
      return false unless is_present(ext)

      BeEF::Core::Configuration.instance.get("beef.extension.#{ext}.enable") == true
    end

    # Checks to see if extension has been loaded
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension is loaded
    def self.is_loaded(ext)
      return false unless is_enabled(ext)

      BeEF::Core::Configuration.instance.get("beef.extension.#{ext}.loaded") == true
    end

    # Loads an extension
    # @param [String] ext the extension key
    # @return [Boolean] whether or not the extension loaded successfully
    def self.load(ext)
      if File.exist? "#{$root_dir}/extensions/#{ext}/extension.rb"
        require "#{$root_dir}/extensions/#{ext}/extension.rb"
        print_debug "Loaded extension: '#{ext}'"
        BeEF::Core::Configuration.instance.set "beef.extension.#{ext}.loaded", true
        return true
      end
      print_error "Unable to load extension '#{ext}'"
      false
    rescue StandardError => e
      print_error "Unable to load extension '#{ext}':"
      print_more e.message
    end
  end
end
