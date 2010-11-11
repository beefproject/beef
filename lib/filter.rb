module BeEF
  
  module Filter
    
    # check if the string is not empty and not nil
    def self.is_non_empty_string?(str)
      return false if str.nil?
      return false if not str.is_a? String
      return false if str.empty?
      true
    end

    # check if the command id valid
    def self.is_valid_commmamd_id?(str)
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
    def self.is_valid_commmamd_module_datastore_key?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return BeEF::Filter.has_valid_key_chars?(str)      
    end

    # check if valid command module datastore value
    def self.is_valid_commmamd_module_datastore_param?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return false if BeEF::Filter.has_null?(str)
      return false if BeEF::Filter.has_non_printable_char?(str)    
      true  
    end

    # check if num chars only
    def self.nums_only?(str)
      not (str =~ /^[\d]+$/).nil?
    end

    # check if hex chars only
    def self.hexs_only?(str)
      not (str =~ /^[0123456789ABCDEFabcdef]+$/).nil?
    end

    # check if first char is a num
    def self.first_char_is_num?(str)
      not (str =~ /^\d.*/).nil?
    end

    # check for word and some punc chars
    def self.has_valid_key_chars?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      (str =~ /[^\w_-]/).nil?
    end
          
    # check for word and underscore chars
    def self.has_valid_param_chars?(str)
      return false if str.nil?
      return false if not str.is_a? String
      return false if str.empty?
      (str =~ /[^\w_]/).nil?
    end
          
    # check for space chars: \t\n\r\f
    def self.has_whitespace_char?(str)
      not (str =~ /\s/).nil?
    end
          
    # check for non word chars: a-zA-Z0-9
    def self.has_nonword_char?(str)
      not (str =~ /\w/).nil?
    end
          
    # check for null char
    def self.has_null? (str)
      not (str =~ /[\000]/).nil?
    end

    # check for non-printalbe char
    def self.has_non_printable_char?(str)
      not (str =~ /[^[:print:]]/m).nil?
    end

    # check if request is valid
    def self.is_valid_request?(str)
      req_parts = str.split(/ |\n/)

      #check verb
      verb = req_parts[0]
      return false if not verb.eql? "GET" or verb.eql? "POST"

      #check uri
      uri = req_parts[1]
      return false if not uri.eql? WEBrick::HTTPUtils.normalize_path(uri)
      
      # check trailer
      trailer = req_parts[2]
      return false if not trailer.eql? "HTTP/1.1" or trailer.eql? "HTTP/1.0"

      # check host
      host_param_key = req_parts[3]
      return false if not host_param_key.eql? "Host:"

      # check ip address of target
      host_param_value = req_parts[4]
      return false if not host_param_value =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
            
      true
    end

  end
  
end
