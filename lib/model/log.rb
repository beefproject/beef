module BeEF
module Models

class Log
  
  include DataMapper::Resource
  
  storage_names[:default] = 'logs'
  
  property :id, Serial
  property :type, Text, :lazy => false
  property :event, Text, :lazy => false
  property :date, DateTime, :lazy => false
  property :zombie_id, Text, :lazy => false
  
end

end
end
