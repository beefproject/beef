module BeEF
module Extension
module Proxy
  
  extend BeEF::API::Extension
  
  @short_name = 'proxy'
  @full_name = 'proxy'
  @description = 'The proxy allow to tunnel HTTP requests to the hooked domain through the victim browser'

end
end
end

require 'webrick/httpproxy'
require 'webrick/httputils'
require 'webrick/httprequest'
require 'webrick/httpresponse'
require 'extensions/requester/models/http'
require 'extensions/proxy/base'
require 'extensions/proxy/zombie'
require 'extensions/proxy/api'
require 'extensions/proxy/handlers/zombie/handler'
