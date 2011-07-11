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

  # check the browser type value - for example, 'FF'
  def self.is_valid_browsername?(str)
    return false if not is_non_empty_string?(str)
    return false if str.length > 2
    return false if has_non_printable_char?(str)  
    true
  end

  # check the os name value - for example, 'Windows XP'
  def self.is_valid_osname?(str)
    return false if not is_non_empty_string?(str)
    return false if has_non_printable_char?(str) 
    return false if str.length < 2
    true
  end

  # verify the browser version string is valid
  def self.is_valid_browserversion?(str)
    return false if not is_non_empty_string?(str)
    return false if has_non_printable_char?(str)  
    return true if str.eql? "UNKNOWN"
    return false if not nums_only?(str) and not is_valid_float?(str)  
    return false if str.length > 10      
    true
  end

  # verify the browser/UA string is valid
  def self.is_valid_browserstring?(str)
    return false if not is_non_empty_string?(str)
    return false if has_non_printable_char?(str)    
    return false if str.length > 200      
    true
  end

  # verify the browser_plugins string is valid
  def self.is_valid_browser_plugins?(str)
    return false if not is_non_empty_string?(str)
    return false if str.length > 400
    if RUBY_VERSION >= "1.9" && str.encoding === Encoding.find('UTF-8')
      return (str =~ /[^\w\d\s()-.,;_!\302\256]/u).nil?
    else
      return (str =~ /[^\w\d\s()-.,;_!\302\256]/n).nil?
    end
  end

end  
end
