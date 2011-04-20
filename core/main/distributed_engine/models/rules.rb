module BeEF
module Core
module DistributedEngine
module Models
  #
  # Table stores the rules for the Distributed Engine.
  #
  class Rules
  
    include DataMapper::Resource
  
    storage_names[:default] = 'extensions.distributed_engine.rules'
  
    property :id, Serial
    property :data, Text
    property :enabled, Boolean
  
  end

end
end
end
end