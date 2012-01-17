#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
