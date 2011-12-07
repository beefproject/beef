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

  # Check the browser type value - for example, 'FF'
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid browser name characters
  def self.is_valid_browsername?(str)
    return false if not is_non_empty_string?(str)
    return false if str.length > 2
    return false if has_non_printable_char?(str)  
    true
  end

  # Check the browser type value - for example, {"FF5":true,"FF":true} & {"S":true}
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid browser type characters
  def self.is_valid_browsertype?(str)
    return false if not is_non_empty_string?(str)
    return false if str.length < 10
    return false if str.length > 50
    return false if has_non_printable_char?(str)
    true
  end

  # Check the Operating System name value - for example, 'Windows XP'
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid Operating System name characters
  def self.is_valid_osname?(str)
    return false if not is_non_empty_string?(str)
    return false if has_non_printable_char?(str) 
    return false if str.length < 2
    true
  end

  # Verify the browser version string is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid browser version characters
  def self.is_valid_browserversion?(str)
    return false if not is_non_empty_string?(str)
    return false if has_non_printable_char?(str)  
    return true if str.eql? "UNKNOWN"
    return false if not nums_only?(str) and not is_valid_float?(str)  
    return false if str.length > 10      
    true
  end

  # Verify the browser/UA string is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid browser / ua string characters
  def self.is_valid_browserstring?(str)
    return false if not is_non_empty_string?(str)
    return false if has_non_printable_char?(str)    
    return false if str.length > 300      
    true
  end
  
  # Verify the cookies are valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid cookie characters
  def self.is_valid_cookies?(str)
    return false if has_non_printable_char?(str)    
    return false if str.length > 2000
    true
  end

  # Verify the screen params are valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid screen param characters
  def self.is_valid_screen_params?(str)
    return false if has_non_printable_char?(str)    
    return false if str.length > 200
    true
  end

  # Verify the window size is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid window size characters
  def self.is_valid_window_size?(str)
    return false if has_non_printable_char?(str)    
    return false if str.length > 200
    true
  end

  # Verify the system platform is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid system platform characters
  def self.is_valid_system_platform?(str)
    return false if has_non_printable_char?(str)
    return false if str.length > 200
    true
  end

  # Verify the browser_plugins string is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid browser plugin characters
  # @note This string can be empty if there are no browser plugins
  # @todo Verify if the ruby version statement is still necessary
  def self.is_valid_browser_plugins?(str)
    return true if not is_non_empty_string?(str)
    return false if str.length > 1000
    if RUBY_VERSION >= "1.9" && str.encoding === Encoding.find('UTF-8')
      return (str =~ /[^\w\d\s()-.,;_!\302\256]/u).nil?
    else
      return (str =~ /[^\w\d\s()-.,;_!\302\256]/n).nil?
    end
  end

end  
end
