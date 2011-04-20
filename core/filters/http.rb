module BeEF  
module Filters
  
  # verify the hostname string is valid
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