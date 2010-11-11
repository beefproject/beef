module BeEF
module Models

class CommandModule
  
  include DataMapper::Resource
  
  storage_names[:default] = 'command_modules'
  
  property :id, Serial
  property :path, Text, :lazy => false
  property :name, Text, :lazy => false
  
  has n, :commands
  
end

end
end