#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Filters
    # Check if the string is not empty and not nil
    #   @param [String] str String for testing
    #   @return [Boolean] Whether the string is not empty
    def self.is_non_empty_string?(str)
      return false if str.nil?
      return false unless str.is_a? String
      return false if str.empty?

      true
    end

    # Check if only the characters in 'chars' are in 'str'
    #   @param [String] chars List of characters to match
    #   @param [String] str String for testing
    #   @return [Boolean] Whether or not the only characters in str are specified in chars
    def self.only?(chars, str)
      regex = Regexp.new('[^' + chars + ']')
      regex.match(str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')).nil?
    end

    # Check if one or more characters in 'chars' are in 'str'
    #   @param [String] chars List of characters to match
    #   @param [String] str String for testing
    #   @return [Boolean] Whether one of the characters exists in the string
    def self.exists?(chars, str)
      regex = Regexp.new(chars)
      !regex.match(str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')).nil?
    end

    # Check for null char
    #   @param [String] str String for testing
    #   @return [Boolean] If the string has a null character
    def self.has_null?(str)
      return false unless is_non_empty_string?(str)

      exists?('\x00', str)
    end

    # Check for non-printable char
    #   @param [String] str String for testing
    #   @return [Boolean] Whether or not the string has non-printable characters
    def self.has_non_printable_char?(str)
      return false unless is_non_empty_string?(str)

      !only?('[:print:]', str)
    end

    # Check if num characters only
    #   @param [String] str String for testing
    #   @return [Boolean] If the string only contains numbers
    def self.nums_only?(str)
      return false unless is_non_empty_string?(str)

      only?('0-9', str)
    end

    # Check if valid float
    #   @param [String] str String for float testing
    #   @return [Boolean] If the string is a valid float
    def self.is_valid_float?(str)
      return false unless is_non_empty_string?(str)
      return false unless only?('0-9\.', str)

      !(str =~ /^\d+\.\d+$/).nil?
    end

    # Check if hex characters only
    #   @param [String] str String for testing
    #   @return [Boolean] If the string only contains hex characters
    def self.hexs_only?(str)
      return false unless is_non_empty_string?(str)

      only?('0123456789ABCDEFabcdef', str)
    end

    # Check if first character is a number
    #   @param [String] String for testing
    #   @return [Boolean] If the first character of the string is a number
    def self.first_char_is_num?(str)
      return false unless is_non_empty_string?(str)

      !(str =~ /^\d.*/).nil?
    end

    # Check for space characters: \t\n\r\f
    #   @param [String] str String for testing
    #   @return [Boolean] If the string has a whitespace character
    def self.has_whitespace_char?(str)
      return false unless is_non_empty_string?(str)

      exists?('\s', str)
    end

    # Check for non word characters: a-zA-Z0-9
    #   @param [String] str String for testing
    #   @return [Boolean] If the string only has alphanums
    def self.alphanums_only?(str)
      return false unless is_non_empty_string?(str)

      only?('a-zA-Z0-9', str)
    end

    # @overload self.is_valid_ip?(ip, version)
    # Checks if the given string is a valid IP address
    #   @param [String] ip string to be tested
    #   @param [Symbol] version IP version (either <code>:ipv4</code> or <code>:ipv6</code>)
    #   @return [Boolean] true if the string is a valid IP address, otherwise false
    #
    # @overload self.is_valid_ip?(ip)
    # Checks if the given string is either a valid IPv4 or IPv6 address
    #   @param [String] ip string to be tested
    #   @return [Boolean] true if the string is a valid IPv4 or IPV6 address, otherwise false
    def self.is_valid_ip?(ip, version = :both)
      return false unless is_non_empty_string?(ip)

      if case version.inspect.downcase
         when /^:ipv4$/
           ip =~ /^((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
             (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])$/x
         when /^:ipv6$/
           ip =~ /^(([0-9a-f]{1,4}:){7,7}[0-9a-f]{1,4}|
             ([0-9a-f]{1,4}:){1,7}:|
             ([0-9a-f]{1,4}:){1,6}:[0-9a-f]{1,4}|
             ([0-9a-f]{1,4}:){1,5}(:[0-9a-f]{1,4}){1,2}|
             ([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,3}|
             ([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,4}|
             ([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,5}|
             [0-9a-f]{1,4}:((:[0-9a-f]{1,4}){1,6})|
             :((:[0-9a-f]{1,4}){1,7}|:)|
             fe80:(:[0-9a-f]{0,4}){0,4}%[0-9a-z]{1,}|
             ::(ffff(:0{1,4}){0,1}:){0,1}
             ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}
             (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|
             ([0-9a-f]{1,4}:){1,4}:
             ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}
             (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/ix
         when /^:both$/
           is_valid_ip?(ip, :ipv4) || is_valid_ip?(ip, :ipv6)
         end
        true
      else
        false
      end
    end

    # Checks if the given string is a valid private IP address
    #   @param [String] ip string for testing
    #   @return [Boolean] true if the string is a valid private IP address, otherwise false
    # @note Includes RFC1918 private IPv4, private IPv6, and localhost 127.0.0.0/8, but does not include local-link addresses.
    def self.is_valid_private_ip?(ip)
      return false unless is_valid_ip?(ip)

      ip =~ /\A(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^::1$)|(^[fF][cCdD])\z/ ? true : false
    end

    # Checks if the given string is a valid TCP port
    #   @param [String] port string for testing
    #   @return [Boolean] true if the string is a valid TCP port, otherwise false
    def self.is_valid_port?(port)
      valid = false
      valid = true if port.to_i > 0 && port.to_i < 2**16
      valid
    end

    # Checks if string is a valid domain name
    #   @param [String] domain string for testing
    #   @return [Boolean] If the string is a valid domain name
    # @note Only validates the string format. It does not check for a valid TLD since ICANN's list of TLD's is not static.
    def self.is_valid_domain?(domain)
      return false unless is_non_empty_string?(domain)
      return true if domain =~ /^[0-9a-z-]+(\.[0-9a-z-]+)*(\.[a-z]{2,}).?$/i

      false
    end

    # Check for valid browser details characters
    #   @param [String] str String for testing
    #   @return [Boolean] If the string has valid browser details characters
    # @note This function passes the \302\256 character which translates to the registered symbol (r)
    def self.has_valid_browser_details_chars?(str)
      return false unless is_non_empty_string?(str)

      (str =~ %r{[^\w\d\s()-.,;:_/!\302\256]}).nil?
    end

    # Check for valid base details characters
    #   @param [String] str String for testing
    #   @return [Boolean] If the string has only valid base characters
    # @note This is for basic filtering where possible all specific filters must be implemented
    # @note This function passes the \302\256 character which translates to the registered symbol (r)
    def self.has_valid_base_chars?(str)
      return false unless is_non_empty_string?(str)

      (str =~ /[^\302\256[:print:]]/).nil?
    end

    # Verify the yes and no is valid
    #   @param [String] str String for testing
    #   @return [Boolean] If the string is either 'yes' or 'no'
    def self.is_valid_yes_no?(str)
      return false if has_non_printable_char?(str)
      return false if str !~ /\A(Yes|No)\z/i

      true
    end
  end
end
