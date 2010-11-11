module BeEF
module Models
  
class Autoloading
  
  include DataMapper::Resource
  
  storage_names[:default] = 'autoloading'
  
  property :id, Serial
  property :in_use, Boolean
  
  belongs_to :command
  
end
  
end
end