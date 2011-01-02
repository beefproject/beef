module BeEF
module Models

class DynamicPayloads
  
  include DataMapper::Resource
  
  storage_names[:default] = 'dynamic_payloads'
  
	property :id, Serial
  	property :name, Text, :lazy => false

	has n, :dynamic_payload_info
  
end

end
end

