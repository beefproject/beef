#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
module Core
module DistributedEngine
module Models

  # @note Table stores the rules for the Distributed Engine.
  class Rules
  
    include DataMapper::Resource
  
    storage_names[:default] = 'extension_distributedengine_rules'
  
    property :id, Serial
    property :data, Text
    property :enabled, Boolean
  
  end

end
end
end
end
