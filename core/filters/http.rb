#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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

  def self.is_valid_verb?(verb)
    ["HEAD", "GET", "POST", "OPTIONS", "PUT", "DELETE"].each {|v| return true if verb.eql? v }
    false
  end

  def self.is_valid_url?(uri)
    return true if !uri.nil?
    # OPTIONS * is not yet supported
    #return true if uri.eql? "*"
    # TODO : CHECK THE normalize_path method and include it somewhere (maybe here)
    #return true if uri.eql? self.normalize_path(uri)
    false
  end

  def self.is_valid_http_version?(version)
    # from browsers the http version contains a space at the end ("HTTP/1.0\r")
    version.gsub!(/[\r]+/,"")
    ["HTTP/1.0", "HTTP/1.1"].each {|v| return true if version.eql? v }
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
