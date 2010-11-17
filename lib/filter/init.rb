module BeEF
  
  module Filter

    # verify the page title string is valid
    def self.is_valid_pagetitle?(str)
      return false if not str.is_a? String
      return false if BeEF::Filter.has_non_printable_char?(str)
      return false if str.length > 50      
      true
    end

    # check the browser type value - for example, 'FF'
    def self.is_valid_browsername?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return false if str.length > 2
      return false if BeEF::Filter.has_non_printable_char?(str)  
      true
    end

    # verify the browser version string is valid
    def self.is_valid_browserversion?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return false if BeEF::Filter.has_non_printable_char?(str)  
      return false if not BeEF::Filter.is_valid_float?(str)  
      return false if str.length > 10      
      true
    end

    # verify the browser/UA string is valid
    def self.is_valid_browserstring?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return false if BeEF::Filter.has_non_printable_char?(str)    
      return false if str.length > 200      
      true
    end

    # verify the hostname string is valid
    def self.is_valid_hostname?(str)
      return false if not BeEF::Filter.is_non_empty_string?(str)
      return false if BeEF::Filter.has_non_printable_char?(str)
      return false if str.length > 255
      return false if (str =~ /^[a-zA-Z0-9][a-zA-Z0-9\-\.]*[a-zA-Z0-9]$/).nil?
      return false if not (str =~ /\.\./).nil?
      return false if not (str =~ /\-\-/).nil?
      
      true
    end

  end
  
end
