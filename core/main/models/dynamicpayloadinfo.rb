module BeEF
module Core
module Models

  class DynamicPayloadInfo
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_dynamicpayloadinfo'
  
    property :id, Serial
    property :name, String, :length => 30
    property :value, String, :length => 255
    property :required, Boolean, :default => false
    property :description, Text, :lazy => false
  
    belongs_to :dynamic_payloads
  
  end

end
end
end