module BeEF
module Core
module Models

  class CommandModule
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_commandmodules'
  
    property :id, Serial
    property :name, Text, :lazy => false
    property :path, Text, :lazy => false
  
    has n, :commands
    has 1, :dynamic_command_info
  
  end
  
end
end
end
