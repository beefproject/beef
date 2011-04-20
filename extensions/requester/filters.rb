module BeEF
  
  module Filters
    
    def self.is_valid_verb?(verb)
      return true if verb.eql? 'GET' or verb.eql? 'POST'
      false
    end

    def self.is_valid_url?(uri)
      return true if uri.eql? WEBrick::HTTPUtils.normalize_path(uri)
      false
    end

    def self.is_valid_http_version?(version)
      return true if version.eql? "HTTP/1.1" or trailer.eql? "HTTP/1.0"
      false
    end

    def self.is_valid_host_str?(host_str)
      return true if host_str.eql? "Host:"
      false
    end

  end
  
end
