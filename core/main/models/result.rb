module BeEF
module Core
module Models
  #
  # Table stores the results from commands.
  #
  class Result
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_results'
  
    property :id, Serial
    property :date, String, :length => 15, :lazy => false
    property :data, Text
  
  end
  
end
end
end