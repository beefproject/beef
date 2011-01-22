module BeEF
  
  module Filter
    
    def self.is_valid_msf_payload_name?(name)
      return false if  only?("a-z_/", name)
      true
    end

  end
  
end