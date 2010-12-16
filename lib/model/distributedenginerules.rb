module BeEF
module Models

class DistributedEngineRules
  
  include DataMapper::Resource
  
  storage_names[:default] = 'distributed_engine_rules'
  
  property :id, Serial
  property :data, Text
  property :enabled, Boolean
  
end

end
end