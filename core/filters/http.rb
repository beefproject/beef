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
module Filters
  
  # Verify the hostname string is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string is a valid hostname
  def self.is_valid_hostname?(str)
    return false if not is_non_empty_string?(str)
    return false if has_non_printable_char?(str)
    return false if str.length > 255
    return false if (str =~ /^[a-zA-Z0-9][a-zA-Z0-9\-\.]*[a-zA-Z0-9]$/).nil?
    return false if not (str =~ /\.\./).nil?
    return false if not (str =~ /\-\-/).nil?      
    true
  end
  
end
end
