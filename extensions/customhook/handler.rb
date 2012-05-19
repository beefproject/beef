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
module BeEF
module Extension
module Customhook
  
    class Handler

    def call(env)
      @body = ''
      @request = Rack::Request.new(env)
      @params = @request.query_string
      @response = Rack::Response.new(body=[], 200, header={})
      config = BeEF::Core::Configuration.instance

      eruby = Erubis::FastEruby.new(File.read(File.dirname(__FILE__)+'/html/index.html'))

      @body << eruby.evaluate({'customhook_target' => config.get("beef.extension.customhook.customhook_target"),
        'customhook_title' => config.get("beef.extension.customhook.customhook_title")})
      
      @response = Rack::Response.new(
            body = [@body],
            status = 200,
            header = {
              'Pragma' => 'no-cache',
              'Cache-Control' => 'no-cache',
              'Expires' => '0',
              'Content-Type' => 'text/html',
              'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => 'POST, GET'
            }
        )
      
    end

    private
    
    # @note Object representing the HTTP request
    @request
    
    # @note Object representing the HTTP response
    @response
    
  end
  
end
end
end
