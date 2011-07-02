#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
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