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
#
# Generic Http Handler that extensions can use to register http
# controllers into the framework.
#
module BeEF
module Extension
module AdminUI
module Handlers
  
  class UI < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard
    
    #
    # Constructor
    #
    def initialize(config, klass)
      super
      @guard = Mutex.new
      @klass = BeEF::Extension::AdminUI::Controllers.const_get(klass.to_s.capitalize)
    end
    
    #
    # Retrieves the request and forwards it to the controller
    #
    def do_GET(request, response)
      @request = request
      @response = response
      
      controller = nil

      controller = @klass.new
      controller.run(@request, @response)
      
      response.header.replace(controller.headers)
      response.body = controller.body.to_s
    end
    
    private
    
    @request
    @response
    
    alias do_POST do_GET
  end
  
end
end
end
end