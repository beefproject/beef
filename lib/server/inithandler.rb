module BeEF
  
  #
  # The http handler that manages the return of the initial browser details.
  #
  class InitHandler < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard
    
    HB = BeEF::Models::Zombie
    BD = BeEF::Models::BrowserDetails
    
    #
    # Class constructor
    #
    def initialize(config)
      # we set up a mutex
      @guard = Mutex.new
    end
    
    #
    # This function receives any POST http requests. We only
    # allow the hooked browser to send back results using POST.
    #
    def do_POST(request, response)
      
      # validate hook session value
      session_id = request.query['BEEFHOOK'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "session_id is nil" if session_id.nil?
      hooked_browser = HB.first(:session => session_id, :has_init => false)
      raise WEBrick::HTTPStatus::BadRequest, "Invalid beef session id: the hooked browser cannot be found in the database" if hooked_browser.nil?
      
      request.query.keys.each{|key|
        next if key.eql? "command_id" or key.eql? "BEEFHOOK" # ignore these params

        # keys and values from the request
        raise WEBrick::HTTPStatus::BadRequest, "Invalid init key" if Filter.has_non_printable_char?(key)
        b64_param = request.query[key]
        raise WEBrick::HTTPStatus::BadRequest, "Invalid init base64 value" if Filter.has_non_printable_char?(b64_param)
        escaped_param = CGI.unescapeHTML(b64_param)
        raise WEBrick::HTTPStatus::BadRequest, "Invalid init escaped value" if Filter.has_non_printable_char?(escaped_param)        
        param = Base64.decode64(escaped_param)
        raise WEBrick::HTTPStatus::BadRequest, "Invalid init value" if Filter.has_non_printable_char?(param)        

        # store the returned browser details
        BD.set(session_id, key, param)
      }

      # init details have been returned so set flag and save
      hooked_browser.has_init = true
      @guard.synchronize {      
        hooked_browser.save
      }
    
      response.body = ''
    end
    
  end
  
end