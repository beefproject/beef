module BeEF
module Extension
module Console

  extend BeEF::API::Extension
  
  #
  # Sets the information for that extension.
  #
  @short_name = @full_name = 'console'
  @description = 'console environment to manage beef'
  
  #
  # Returns true of the verbose option has been enabled for the console.
  # False if not.
  #
  #  Example:
  #
  #   $ ruby console.rb -v
  #     BeEF::Extension::Console.verbose? # => true
  #
  #   $ ruby console.rb
  #     BeEF::Extension::Console.verbose? # => false
  #
  def self.verbose?
    CommandLine.parse[:verbose]
  end
  
  #
  # Returns true if we should reset the database. False if not.
  #
  #   $ ruby console.rb -x
  #     BeEF::Extension::Console.resetdb? # => true
  #
  #   $ ruby console.rb
  #     BeEF::Extension::Console.resetdb? # => false
  #
  def self.resetdb?
    CommandLine.parse[:resetdb]
  end
  
end
end
end

require 'extensions/console/banners'
require 'extensions/console/commandline'
