module BeEF
  
  module Filter

    # check if request is valid
    # @param: {WEBrick::HTTPUtils::FormData} request object
    def self.is_valid_request?(request)
      #check a webrick object is sent
      raise 'your request is of invalid type' if not request.is_a? WEBrick::HTTPRequest
      
      #check http method
      raise 'only GET or POST requests are supported for http requests' if not request.request_method.eql? 'GET' or request.request_method.eql? 'POST'
      
      #check uri
      raise 'the uri is missing' if not request.unparsed_uri
      
      #check host
      raise 'http host missing' if request.host.nil?
      
      #check domain
      raise 'invalid http domain' if not URI.parse(request.host)
      
      true
    end

  end
  
end
