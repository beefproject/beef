#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
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
