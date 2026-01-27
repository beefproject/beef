#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Filters
    # Check the browser type value - for example, 'FF'
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid browser name characters
    def self.is_valid_browsername?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if str.length > 2
      return false if has_non_printable_char?(str)

      true
    end

    # Check the Operating System name value - for example, 'Windows XP'
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid Operating System name characters
    def self.is_valid_osname?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length < 2

      true
    end

    # Check the Hardware name value - for example, 'iPhone'
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid Hardware name characters
    def self.is_valid_hwname?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length < 2

      true
    end

    # Verify the browser version string is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid browser version characters
    def self.is_valid_browserversion?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return true if str.eql? 'UNKNOWN'
      return true if str.eql? 'ALL'
      return false if !nums_only?(str) && !str.match(/\A(0|[1-9][0-9]{0,3})(\.(0|[1-9][0-9]{0,3})){0,3}\z/)
      return false if str.length > 20

      true
    end

    # Verify the os version string is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid os version characters
    def self.is_valid_osversion?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return true if str.eql? 'UNKNOWN'
      return true if str.eql? 'ALL'
      return false unless BeEF::Filters.only?('a-zA-Z0-9.<=> ', str)
      return false if str.length > 20

      true
    end

    # Verify the browser/UA string is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid browser / ua string characters
    def self.is_valid_browserstring?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length > 300

      true
    end

    # Verify the cookies are valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid cookie characters
    def self.is_valid_cookies?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length > 2000

      true
    end

    # Verify the system platform is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid system platform characters
    def self.is_valid_system_platform?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length > 200

      true
    end

    # Verify the date stamp is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid date stamp characters
    def self.is_valid_date_stamp?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length > 200

      true
    end

    # Verify the CPU type string is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid CPU type characters
    def self.is_valid_cpu?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length > 200

      true
    end

    # Verify the memory string is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid memory type characters
    def self.is_valid_memory?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length > 200

      true
    end

    # Verify the GPU type string is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid GPU type characters
    def self.is_valid_gpu?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if has_non_printable_char?(str)
      return false if str.length > 200

      true
    end

    # Verify the browser_plugins string is valid
    # @param [String] str String for testing
    # @return [Boolean] If the string has valid browser plugin characters
    # @note This string can be empty if there are no browser plugins
    # @todo Verify if the ruby version statement is still necessary
    def self.is_valid_browser_plugins?(str) # rubocop:disable Naming/PredicatePrefix
      return false unless is_non_empty_string?(str)
      return false if str.length > 1000

      if str.encoding == Encoding.find('UTF-8') # Style/CaseEquality: Avoid the use of the case equality operator `===`.
        (str =~ /[^\w\d\s()-.,';_!\302\256]/u).nil?
      else
        (str =~ /[^\w\d\s()-.,';_!\302\256]/n).nil?
      end
    end
  end
end
