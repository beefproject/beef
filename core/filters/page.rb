module BeEF
module Filters
  
  # verify the page title string is valid
  def self.is_valid_pagetitle?(str)
    return false if not str.is_a? String
    return false if has_non_printable_char?(str)
    return false if str.length > 50      
    true
  end
  
end
end