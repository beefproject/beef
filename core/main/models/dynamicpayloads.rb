module BeEF
module Core
module Models

  class DynamicPayloads
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_dynamicpayloads'
  
    property :id, Serial
    property :name, Text, :lazy => false
  
  	has n, :dynamic_payload_info
  
  end

end
end
end