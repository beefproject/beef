#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Filters
    
  # Check if the string is a valid path from a HTTP request
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid path characters
  def self.is_valid_path_info?(str)
    return false if str.nil?
    return false if not str.is_a? String
    return false if has_non_printable_char?(str)
    true
  end

  # Check if the command id valid
  # @param [String] str String for testing
  # @return [Boolean] If the string is a valid command id
  def self.is_valid_command_id?(str)
    return false if not is_non_empty_string?(str)
    return false if not nums_only?(str)   
    true
  end

  # Check if the session id valid
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid hook session id characters
  def self.is_valid_hook_session_id?(str)
    return false if not is_non_empty_string?(str)
    return false if not has_valid_key_chars?(str) 
    true
  end

  # Check if valid command module datastore key
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid command module datastore key characters
  def self.is_valid_command_module_datastore_key?(str)
    return false if not is_non_empty_string?(str)
    return false if not has_valid_key_chars?(str)      
    true
  end

  # Check if valid command module datastore value
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid command module datastore param characters
  def self.is_valid_command_module_datastore_param?(str)
    return false if has_null?(str)
    return false if not has_valid_base_chars?(str)
    true
  end

  # Check for word and some punc chars
  # @param [String] str String for testing
  # @return [Boolean] If the string has valid key characters
  def self.has_valid_key_chars?(str)
    return false if not is_non_empty_string?(str)
    return false if not has_valid_base_chars?(str)
    true
  end

  # Check for word and underscore chars
  # @param [String] str String for testing
  # @return [Boolean] If the sting has valid param characters
  def self.has_valid_param_chars?(str)
    return false if str.nil?
    return false if not str.is_a? String
    return false if str.empty?
    return false if not (str =~ /[^\w_\:]/).nil?
    true
  end

end
end
