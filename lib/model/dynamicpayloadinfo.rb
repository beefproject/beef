module BeEF
module Models

class DynamicPayloadInfo
  
  include DataMapper::Resource
  
  storage_names[:default] = 'dynamic_payload_info'
  
	property :id, Serial
	property :name, String, :length => 15
	property :value, String, :length => 30
        property :required, Boolean, :default => false
  	property :description, Text, :lazy => false
	belongs_to :dynamic_payloads
  
end

end
end

