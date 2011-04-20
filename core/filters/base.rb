module BeEF
module Filters
  
  # check if the string is not empty and not nil
  def self.is_non_empty_string?(str)
    return false if str.nil?
    return false if not str.is_a? String
    return false if str.empty?
    true
  end

  # check if only the characters in 'chars' are in 'str'
  def self.only?(chars, str)
    regex = Regexp.new('[^' + chars + ']')
    regex.match(str).nil?
  end
        
  # check if one or more characters in 'chars' are in 'str'
  def self.exists?(chars, str)
    regex = Regexp.new(chars)
    not regex.match(str).nil?
  end
        
  # check for null char
  def self.has_null? (str)
    return false if not is_non_empty_string?(str)
    exists?('\x00', str)
  end

  # check for non-printalbe char
  def self.has_non_printable_char?(str)
    return false if not is_non_empty_string?(str)
    not only?('[:print:]', str)
  end

  # check if num chars only
  def self.nums_only?(str)
    return false if not is_non_empty_string?(str)
    only?('0-9', str)
  end

  # check if valid float
  def self.is_valid_float?(str)
    return false if not is_non_empty_string?(str)
    return false if not only?('0-9\.', str)
    not (str =~ /^[\d]+\.[\d]+$/).nil?
  end

  # check if hex chars only
  def self.hexs_only?(str)
    return false if not is_non_empty_string?(str)
    only?('0123456789ABCDEFabcdef', str)
  end

  # check if first char is a num
  def self.first_char_is_num?(str)
    return false if not is_non_empty_string?(str)
    not (str =~ /^\d.*/).nil?
  end

  # check for space chars: \t\n\r\f
  def self.has_whitespace_char?(str)
    return false if not is_non_empty_string?(str)
    exists?('\s', str)
  end

  # check for non word chars: a-zA-Z0-9
  def self.alphanums_only?(str)
    return false if not is_non_empty_string?(str)
    only?("a-zA-Z0-9", str)
  end
        
  # check if valid ip address string
  def self.is_valid_ip?(ip)
    return true if ip =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
    false
  end

  # check for valid browser details chars
  def self.has_valid_browser_details_chars?(str)
    return false if not is_non_empty_string?(str)
    not (str =~ /[^\w\d\s()-.,;:_\/!\302\256]/).nil? # \302\256 is the (r) character 
  end  

  # check for valid base details chars
  # this is for basic flitering where possible all specific filters must be implemented
  def self.has_valid_base_chars?(str)
    return false if not is_non_empty_string?(str)
    (str =~ /[^\302\256[:print:]]/).nil? # \302\256 is the (r) character 
  end  
  
end
end