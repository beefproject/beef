module BeEF
module Models

class OptionCache
  
  include DataMapper::Resource
  
  storage_names[:default] = 'option_cache'
  
  property :id, Serial
  property :name, Text
  property :value, Text
  
end

end
end
