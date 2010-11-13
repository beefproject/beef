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
    # @param: {WEBrick::HTTPUtils::FormData} request object
    def self.is_valid_request?(request)
      #check a webrick object is sent
      raise 'your request is of invalide type' if not request.is_a? WEBrick::HTTPRequest
      
      #check http method
      raise 'only GET or POST requests are supported for http requests' if not request.request_method.eql? 'GET' or request.request_method.eql? 'POST'
      
      #check uri
      raise 'the uri is missing' if not webrick.unparsed_uri
      
      #check host
      raise 'http host missing' if request.host.nil?
      
      #check domain
      raise 'invalid http domain' if not URI.parse(request.host)
      
      true
    end

  end
  
end
