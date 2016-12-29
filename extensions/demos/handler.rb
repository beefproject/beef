#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Demos

  class Handler

    def initialize(file_path)
      if File.exists?(file_path)
        @file_path = file_path
      else
        print_error "[Demos] File does not exist: #{file_path}"
      end
    end

    def call(env)
      @body = ''
      @request = Rack::Request.new(env)
      @params = @request.query_string
      @response = Rack::Response.new(body=[], 200, header={})
      config = BeEF::Core::Configuration.instance
      eruby = Erubis::FastEruby.new(File.read(@file_path))
      @body << eruby.evaluate({
        'hook_uri' => config.get("beef.http.hook_file")
      })

      @response = Rack::Response.new(
        body = [@body],
        status = 200,
        header = {
          'Pragma' => 'no-cache',
          'Cache-Control' => 'no-cache',
          'Expires' => '0',
          'Content-Type' => 'text/html'
        }
      )
 
    end

    private

    # @note String representing the absolute path to the .html file
    @file_path

    # @note Object representing the HTTP request
    @request

    # @note Object representing the HTTP response
    @response

  end

end
end
end
