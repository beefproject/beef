#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Proxy
  
  extend BeEF::API::Extension
  
  @short_name = 'proxy'
  @full_name = 'proxy'
  @description = 'The tunneling proxy allows HTTP requests to the hooked domain to be tunneled through the victim browser'

end
end
end

require 'extensions/requester/models/http'
#require 'extensions/proxy/models/http'
require 'extensions/proxy/proxy'
require 'extensions/proxy/api'
