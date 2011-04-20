# The following file contains patches for WEBrick.
module WEBrick
  
  class HTTPRequest
    
    # I'm patching the HTTPRequest class so that it when it receives POST
    # http requests, it parses the query present in the body even if the
    # content type is not set.
    #
    # The reason for this patch is that when a zombie sends back data to
    # BeEF, that data was not parsed because by default the content-type
    # was not set directly. I prefer patching WEBrick rather than editing
    # the BeEFJS library because cross domain http requests would be harder
    # to implement at the server level.
    #
    # Note: this function would need to be modified if we ever needed to
    # use multipart POST requests.
    def parse_query()
      begin
        if @request_method == "GET" || @request_method == "HEAD"
          @query = HTTPUtils::parse_query(@query_string)
        elsif @request_method == 'POST' || self['content-type'] =~ /^application\/x-www-form-urlencoded/
          @query = HTTPUtils::parse_query(body)
        elsif self['content-type'] =~ /^multipart\/form-data; boundary=(.+)/
          boundary = HTTPUtils::dequote($1)
          @query = HTTPUtils::parse_form_data(body, boundary)
        else
          @query = Hash.new
        end
      rescue => ex
        raise HTTPStatus::BadRequest, ex.message
      end
    end
    
    def get_cookie_value(name)
      
      return nil if name.nil?
      
      @cookies.each{|cookie|
        c = WEBrick::Cookie.parse_set_cookie(cookie.to_s)
        return c.value if (c.name.to_s.eql? name)
      }
      
      nil
      
    end
    
    def get_referer_domain
  
      referer = header['referer'][0]
      
      if referer =~ /\:\/\/([0-9a-zA-A\.]*(\:[0-9]+)?)\//   
        return $1
      end
      
      nil

    end

    def get_hook_session_id()
      
      config = BeEF::Core::Configuration.instance
      hook_session_name = config.get('beef.http.hook_session_name')
      
      @query[hook_session_name] || nil
       
    end

    # return the command module command_id value from the request
    def get_command_id()
      @query['command_id'] || nil
    end

    
  end
  
end
