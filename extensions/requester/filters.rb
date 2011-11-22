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
      #TODO : CHECK THE normalize_path method and include it somewhere (maybe here)
      return true if uri.eql? self.normalize_path(uri)
      false
    end

    def self.is_valid_http_version?(version)
      # from browsers the http version contains a space at the end ("HTTP/1.0\r")
      version.gsub!(/[\r]+/,"")
      return true if "HTTP/1.1".eql?(version) or "HTTP/1.0".eql?(version)
      false
    end

    def self.is_valid_host_str?(host_str)
      # from browsers the host header contains a space at the end
      host_str.gsub!(/[\r]+/,"")
      return true if "Host:".eql?(host_str)
      false
    end

    def normalize_path(path)
      print_error "abnormal path `#{path}'" if path[0] != ?/
      ret = path.dup

      ret.gsub!(%r{/+}o, '/')                    # //      => /
      while ret.sub!(%r'/\.(?:/|\Z)', '/'); end  # /.      => /
      while ret.sub!(%r'/(?!\.\./)[^/]+/\.\.(?:/|\Z)', '/'); end # /foo/.. => /foo

      print_error "abnormal path `#{path}'" if %r{/\.\.(/|\Z)} =~ ret
      ret
    end

  end
  
end
