#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

class OptionCache
  
  include DataMapper::Resource
  
  storage_names[:default] = 'core_optioncache'
  
  property :id, Serial
  property :name, Text
  property :value, Text
  
end

end
end
end
