#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
  
  class UI

    #
    # Constructor
    #
    def initialize(klass)
      # @todo Determine why this class is calling super?
      #super
      @klass = BeEF::Extension::AdminUI::Controllers.const_get(klass.to_s.capitalize)
    end

    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new(env)

      controller = @klass.new
      controller.run(@request, @response)

      @response = Rack::Response.new(
           body = [controller.body],
            status = controller.status,
            header = controller.headers
          )

    end
    
    private

    @request
    @response

  end
  
end
end
end
end
