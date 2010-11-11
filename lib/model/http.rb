module BeEF
module Models

  class Http
  
    include DataMapper::Resource
    
    storage_names[:default] = 'http'
    
    property :id, Serial
    property :request, Text, :lazy => true
    property :response, Text, :lazy => true
    property :method, Text, :lazy => false
    property :content_length, Text, :lazy => false, :default => 0
    property :domain, Text, :lazy => false
    property :path, Text, :lazy => false
    property :date, DateTime, :lazy => false
    property :has_ran, Boolean, :default => false
    
  end
  
end
end