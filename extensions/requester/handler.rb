module BeEF
module Extension
module Requester
    
  #
  # The http handler that manages the Requester.
  #
  class Handler < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard
    
    H = BeEF::Core::Models::Http
    Z = BeEF::Core::Models::HookedBrowser
    
    #
    # Class constructor
    #
    def initialize(data)
      # we set up a mutex
      @guard = Mutex.new
      @data = data
      setup()
    end
    
    def setup()
      # validates the hook token
      beef_hook = @data['beefhook'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "beef_hook is null" if beef_hook.nil?
      
      # validates the request id
      request_id = @data['cid'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "request_id is null" if request_id.nil?
      
      # validates that a hooked browser with the beef_hook token exists in the db
      zombie_db = Z.first(:session => beef_hook) || nil
      raise WEBrick::HTTPStatus::BadRequest, "Invalid beef hook id: the hooked browser cannot be found in the database" if zombie_db.nil?
      
      # validates that we have such a http request saved in the db
      http_db = H.first(:id => request_id.to_i, :hooked_browser_id => zombie_db.id) || nil
      raise WEBrick::HTTPStatus::BadRequest, "Invalid http_db: no such request found in the database" if http_db.nil?
      
      # validates that the http request has not be ran before
      raise WEBrick::HTTPStatus::BadRequest, "This http request has been saved before" if http_db.has_ran.eql? true
      
      # validates the body
      body = @data['results'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "body is null" if body.nil?
      
      # save the results in the database
      http_db.response = body
      http_db.has_ran = true
      http_db.save
      
    end
    
  end
  
end
end
end
