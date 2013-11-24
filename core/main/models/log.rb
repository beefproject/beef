#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

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
