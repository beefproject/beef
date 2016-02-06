#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Filters
  
  # Verify the page title string is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string is a valid page title
  def self.is_valid_pagetitle?(str)
    return false unless str.is_a? String
    return false if has_non_printable_char?(str)
    return false if str.length > 500 # CxF Increased this because some page titles are MUCH longer
    true
  end

  # Verify the page referrer string is valid
  # @param [String] str String for testing
  # @return [Boolean] If the string is a valid referrer
  def self.is_valid_pagereferrer?(str)
    return false unless str.is_a? String
    return false if has_non_printable_char?(str)
    return false if str.length > 350
    true
  end
  
end
end
