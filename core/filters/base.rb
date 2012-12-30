#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Filters
  
  # Check if the string is not empty and not nil
  # @param [String] str String for testing
  # @return [Boolean] Whether the string is not empty
  def self.is_non_empty_string?(str)
    return false if str.nil?
    return false if not str.is_a? String
    return false if str.empty?
    true
  end

  # Check if only the characters in 'chars' are in 'str'
  # @param [String] chars List of characters to match
  # @param [String] str String for testing
  # @return [Boolean] Whether or not the only characters in str are specified in chars
  def self.only?(chars, str)
    regex = Regexp.new('[^' + chars + ']')
    regex.match(str).nil?
  end
        
  # Check if one or more characters in 'chars' are in 'str'
  # @param [String] chars List of characters to match
  # @param [String] str String for testing
  # @return [Boolean] Whether one of the characters exists in the string
  def self.exists?(chars, str)
    regex = Regexp.new(chars)
    not regex.match(str).nil?
  end
        
  # Check for null char
  # @param [String] str String for testing
  # @return [Boolean] If the string has a null character
  def self.has_null? (str)
    return false if not is_non_empty_string?(str)
    exists?('\x00', str)
  end

  # Check for non-printable char
  # @param [String] str String for testing
  # @return [Boolean] Whether or not the string has non-printable characters
  def self.has_non_printable_char?(str)
    return false if not is_non_empty_string?(str)
    not only?('[:print:]', str)
  end

  # Check if num characters only
  # @param [String] str String for testing
  # @return [Boolean] If the string only contains numbers
  def self.nums_only?(str)
    return false if not is_non_empty_string?(str)
    only?('0-9', str)
  end

  # Check if valid float
  # @param [String] str String for float testing
  # @return [Boolean] If the string is a valid float
  def self.is_valid_float?(str)
    return false if not is_non_empty_string?(str)
    return false if not only?('0-9\.', str)
    not (str =~ /^[\d]+\.[\d]+$/).nil?
  end

  # Check if hex characters only
  # @param [String] str String for testing
  # @return [Boolean] If the string only contains hex characters
  def self.hexs_only?(str)
    return false if not is_non_empty_string?(str)
    only?('0123456789ABCDEFabcdef', str)
  end

  # Check if first character is a number
  # @param [String] String for testing
  # @return [Boolean] If the first character of the string is a number
  def self.first_char_is_num?(str)
    return false if not is_non_empty_string?(str)
    not (str =~ /^\d.*/).nil?
  end

  # Check for space characters: \t\n\r\f
  # @param [String] str String for testing
  # @return [Boolean] If the string has a whitespace character
  def self.has_whitespace_char?(str)
    return false if not is_non_empty_string?(str)
    exists?('\s', str)
  end

  # Check for non word characters: a-zA-Z0-9
  # @param [String] str String for testing
  # @return [Boolean] If the string only has alphanums
  def self.alphanums_only?(str)
    return false if not is_non_empty_string?(str)
    only?("a-zA-Z0-9", str)
  end
        
  # Check if valid ip address string
  # @param [String] ip String for testing
  # @return [Boolean] If the string is a valid IP address
  # @note only IPv4 compliant
  def self.is_valid_ip?(ip)
    return false if not is_non_empty_string?(ip)
    return true if ip =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
    false
  end

  # Check for valid browser details characters
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid browser details characters
  # @note This function passes the \302\256 character which translates to the registered symbol (r)
  def self.has_valid_browser_details_chars?(str)
    return false if not is_non_empty_string?(str)
    not (str =~ /[^\w\d\s()-.,;:_\/!\302\256]/).nil?  
  end  

  # Check for valid base details characters
  # @param [String] str String for testing
  # @return [Boolean] If the string has only valid base characters
  # @note This is for basic filtering where possible all specific filters must be implemented
  # @note This function passes the \302\256 character which translates to the registered symbol (r)
  def self.has_valid_base_chars?(str)
    return false if not is_non_empty_string?(str)
    (str =~ /[^\302\256[:print:]]/).nil? 
  end  

  # Verify the yes and no is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string is either 'yes' or 'no'
  # @todo Confirm this is case insensitive
  def self.is_valid_yes_no?(str)
    return false if has_non_printable_char?(str)
    return false if str !~ /^(Yes|No)$/
    return false if str.length > 200
    true
  end
  
end
end
