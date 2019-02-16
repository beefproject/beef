#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models

  class CommandModule
  
    include DataMapper::Resource
  
    storage_names[:default] = 'core_commandmodules'
 
    # @note command module ID
    property :id, Serial

    # @note command module name
    property :name, Text, :lazy => false

    # @note command module path
    property :path, Text, :lazy => false
  
    has n, :commands
  end
  
end
end
end
