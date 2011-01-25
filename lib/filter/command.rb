module BeEF
  
  module Filter
    
    # check if the string is a valid path from a HTTP request
    def self.is_valid_path_info?(str)
      return false if str.nil?
      return false if not str.is_a? String
      return false if BeEF::Filter.has_non_printable_char?(str)
      true
    end

    # check if the command id valid
    def self.is_valid_command_id?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return false if not BeEF::Filter.nums_only?(str)   
      true
    end

    # check if the session id valid
    def self.is_valid_hook_session_id?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return false if not BeEF::Filter.has_valid_key_chars?(str)   
      true
    end

    # check if valid command module datastore key
    def self.is_valid_command_module_datastore_key?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return BeEF::Filter.has_valid_key_chars?(str)      
    end

    # check if valid command module datastore value
    def self.is_valid_command_module_datastore_param?(str)
      return false if BeEF::Filter.has_null?(str)
      return BeEF::Filter.has_valid_key_chars?(str)     
      true  
    end

    # check for word and some punc chars
    def self.has_valid_key_chars?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      (str =~ /[^\w\d\s()-.,;_\302\256]/).nil? # \302\256 is the (r) character 
    end

    # check for word and underscore chars
    def self.has_valid_param_chars?(str)
      return false if str.nil?
      return false if not str.is_a? String
      return false if str.empty?
      (str =~ /[^\w_]/).nil?
    end

  end
  
end
