module BeEF
  #
  # Use this module to check the current settings of BeEF.
  #
  #  Examples:
  #
  #     BeEF::Settings.console? # => returns true if the console extension exists and is loaded.
  #
  module Settings
    
    #
    # Checks if an extension exists in the framework.
    # Returns true if the extension exists, false if not.
    #
    #  Example:
    #
    #     extension_exists?('Console') # => true
    #     extension_exists?('abcdegh') # => false
    #
    def self.extension_exists?(beef_extension)
      BeEF::Extension.const_defined?(beef_extension)
    end
    
    #
    # Returns true of the extension Console has been loaded
    #
    def self.console?
      self.extension_exists?('Console')
    end
    
  end
end