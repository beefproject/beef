#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Network
  
  extend BeEF::API::Extension
  
  @short_name = 'network'
  @full_name = 'Network'
  @description = "This extension provides a simple interface for interacting with hosts on a zombie browser's local area networks."

end
end
end

require 'extensions/network/models/network_host'
require 'extensions/network/models/network_service'
require 'extensions/network/api'
require 'extensions/network/rest/network'
require 'dm-serializer'

