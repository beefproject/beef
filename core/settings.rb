#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Settings

    # Checks if an extension exists in the framework.
    # @param [String] beef_extension extension class
    # @return [Boolean] if the extension exists
    # @deprecated Use #{BeEF::Extension.is_present()} instead of this method.
    #   This method bypasses the configuration system.
    def self.extension_exists?(beef_extension)
      BeEF::Extension.const_defined?(beef_extension)
    end

    # Checks to see if the console extensions has been loaded
    # @return [Boolean] if the console extension has been loaded
    # @deprecated Use #{BeEF::Extension.is_loaded()} instead of this method.
    #   This method bypasses the configuration system.
    def self.console?
      self.extension_exists?('Console')
    end

  end
end
