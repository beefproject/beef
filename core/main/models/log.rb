module BeEF
module Core
module Models
  #
  # This table stores the logs from the framework.
  #
  # See BeEF::Core::Logger for how to log events.
  #
  class Log
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_logs'
  
    property :id, Serial
    property :type, Text, :lazy => false
    property :event, Text, :lazy => false
    property :date, DateTime, :lazy => false
    property :hooked_browser_id, Text, :lazy => false
  
  end
end
end
end