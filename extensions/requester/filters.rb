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
    
    def self.is_valid_verb?(verb)
      ["HEAD", "GET", "POST", "OPTIONS", "PUT", "DELETE"].each {|v| return true if verb.eql? v }
      false
    end

    def self.is_valid_url?(uri)
      # OPTIONS * is not yet supported
      # return true if uri.eql? "*"
      return true if uri.eql? WEBrick::HTTPUtils.normalize_path(uri)
      false
    end

    def self.is_valid_http_version?(version)
      return true if version.eql? "HTTP/1.1" or version.eql? "HTTP/1.0"
      false
    end

    def self.is_valid_host_str?(host_str)
      return true if host_str.eql? "Host:"
      false
    end

  end
  
end
