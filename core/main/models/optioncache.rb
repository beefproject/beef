module BeEF
module Core
module Models

class OptionCache
  
  include DataMapper::Resource
  
  storage_names[:default] = 'core_optioncache'
  
  property :id, Serial
  property :name, Text
  property :value, Text
  
end

end
end
end
