module BeEF
module Filters
    
  # check if the string is a valid path from a HTTP request
  def self.is_valid_path_info?(str)
    return false if str.nil?
    return false if not str.is_a? String
    return false if has_non_printable_char?(str)
    true
  end

  # check if the command id valid
  def self.is_valid_command_id?(str)
    return false if not is_non_empty_string?(str)
    return false if not nums_only?(str)   
    true
  end

  # check if the session id valid
  def self.is_valid_hook_session_id?(str)
    return false if not is_non_empty_string?(str)
    return false if not has_valid_key_chars?(str) 
    true
  end

  # check if valid command module datastore key
  def self.is_valid_command_module_datastore_key?(str)
    return false if not is_non_empty_string?(str)
    return false if not has_valid_key_chars?(str)      
    true
  end

  # check if valid command module datastore value
  def self.is_valid_command_module_datastore_param?(str)
    return false if has_null?(str)
    return false if not has_valid_base_chars?(str)
    true
  end

  # check for word and some punc chars
  def self.has_valid_key_chars?(str)
    return false if not is_non_empty_string?(str)
    return false if not has_valid_base_chars?(str)
    true
  end

  # check for word and underscore chars
  def self.has_valid_param_chars?(str)
    return false if str.nil?
    return false if not str.is_a? String
    return false if str.empty?
    return false if not (str =~ /[^\w_]/).nil?
    true
  end

end
end