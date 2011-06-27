module BeEF
module Core
module Models

  class DynamicCommandInfo
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_dynamiccommandinfo'
  
  	property :id, Serial
    property :name, Text, :lazy => false
    property :description, Text, :lazy => false
  	property :targets, Text, :lazy => false
  	belongs_to :command_module
  
  end

end
end
end