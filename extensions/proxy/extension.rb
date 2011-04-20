module BeEF
module Extension
module Proxy
  
  extend BeEF::API::Extension
  
  @short_name = 'proxy'
  
  @full_name = 'proxy'
  
  @description = 'allows proxy communication with a zombie'

end
end
end

require 'webrick/httpproxy'
require 'webrick/httputils'
require 'webrick/httprequest'
require 'webrick/httpresponse'
require 'extensions/proxy/models/http'
require 'extensions/proxy/base'
require 'extensions/proxy/zombie'
require 'extensions/proxy/api'
require 'extensions/proxy/handlers/zombie/handler'
