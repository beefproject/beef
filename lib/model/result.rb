module BeEF
module Models
  
class Result
  
  include DataMapper::Resource
  
  storage_names[:default] = 'results'
  
  property :id, Serial
  property :date, String, :length => 15, :lazy => false
  property :data, Text
  
end
  
end
end