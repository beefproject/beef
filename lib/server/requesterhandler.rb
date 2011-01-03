module BeEF
  
  #
  # The http handler that manages the Requester.
  #
  class RequesterHandler < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard
    
    H = BeEF::Models::Http
    Z = BeEF::Models::Zombie
    
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
      # validates the hook token
      beef_hook = request.query['BEEFHOOK'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "beef_hook is null" if beef_hook.nil?
      
      # validates the request id
      request_id = request.query['id'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "request_id is null" if request_id.nil?
      
      # validates that a hooked browser with the beef_hook token exists in the db
      zombie_db = Z.first(:session => beef_hook) || nil
      raise WEBrick::HTTPStatus::BadRequest, "Invalid beef hook id: the hooked browser cannot be found in the database" if zombie_db.nil?
      
      # validates that we have such a http request saved in the db
      http_db = H.first(:id => request_id.to_i, :zombie_id => zombie_db.id) || nil
      raise WEBrick::HTTPStatus::BadRequest, "Invalid http_db: no such request found in the database" if http_db.nil?
      
      # validates that the http request has not be ran before
      raise WEBrick::HTTPStatus::BadRequest, "This http request has been saved before" if http_db.has_ran.eql? true
      
      # validates the body
      body = request.query['body'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "body is null" if body.nil?
      
      @guard.synchronize {
        # save the results in the database
        http_db.response = body
        http_db.has_ran = true
        http_db.save
      }
      
      response.set_no_cache()
      response.header['Content-Type'] = 'text/javascript' 
      response.header['Access-Control-Allow-Origin'] = '*'
      response.header['Access-Control-Allow-Methods'] = 'POST'
      response.body = ''
    end
    
  end
  
end