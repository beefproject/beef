#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

  class CommandModule
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_commandmodules'
  
    property :id, Serial
    property :name, Text, :lazy => false
    property :path, Text, :lazy => false
  
    has n, :commands
  end
  
end
end
end
