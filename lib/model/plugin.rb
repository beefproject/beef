module BeEF
module Models
  
  class Plugin
    
    include DataMapper::Resource
  
    storage_names[:default] = 'plugins'
  
    property :id, Serial
    property :data, Text, :lazy => false
    property :path, Text, :lazy => false
    
  end

end
end