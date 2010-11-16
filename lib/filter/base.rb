module BeEF
  
  module Filter
    
    # check if the string is not empty and not nil
    def self.is_non_empty_string?(str)
      return false if str.nil?
      return false if not str.is_a? String
      return false if str.empty?
      true
    end

    # check if num chars only
    def self.nums_only?(str)
      not (str =~ /^[\d]+$/).nil?
    end

    # check if valid float
    def self.is_valid_float?(str)
      not (str =~ /^[\d]+\.[\d]+$/).nil?
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

  end
  
end
