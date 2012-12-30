#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
