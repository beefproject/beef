module BeEF
module API
  #
  # All modules that extend this API module will be considered as extensions to the
  # core of BeEF.
  #
  #  Examples:
  #   
  #     module A
  #       extend BeEF::API::Extension
  #     end
  #
  module Extension
    
    attr_reader :full_name, :short_name, :description
  
    @full_name = ''
    @short_name = ''
    @description = ''
    
  end
  
end
end