module BeEF
module Models

class DynamicCommandInfo
  
  include DataMapper::Resource
  
  storage_names[:default] = 'dynamic_command_info'
  
	property :id, Serial
  property :name, Text, :lazy => false
  property :description, Text, :lazy => false
	belongs_to :command_module
  
end

end
end

