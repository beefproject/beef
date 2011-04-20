module BeEF
module Core
module Models

class OptionCache
  
  include DataMapper::Resource
  
  storage_names[:default] = 'core.option_cache'
  
  property :id, Serial
  property :name, Text
  property :value, Text
  
end

end
end
end
