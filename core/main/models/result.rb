#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

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
