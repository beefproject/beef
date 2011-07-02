#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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
module Core
  #
  # This class takes care of logging events in the db.
  #
  #   Example:
  #
  #     logger = BeEF::Core::Logger.instance
  #     logger.register('Authentication', 'User with ip 127.0.0.1 has successfully authenticated into the application') # => true
  #
  #     zombie_id = 1
  #     logger.register('Zombie', '123.456.789.123 just joined the horde', zombie_id) # => true
  #
  class Logger
    
    include Singleton
    
    #
    # Constructor
    #
    def initialize
      @logs = BeEF::Core::Models::Log
    end
  
    #
    # Registers a new event in the logs
    #
    # @param: {String} the origine of the event (i.e. Authentication, Zombie)
    # @param: {String} the event description
    # @param: {Integer} the id of the hooked browser affected (default = 0 if no HB)
    #
    def register(from, event, zombie = 0)
      # type conversion to enforce standards
      zombie = zombie.to_i
      
      # arguments type checking
      raise Exception::TypeError, '"from" needs to be a string' if not from.string?
      raise Exception::TypeError, '"event" needs to be a string' if not event.string?
      raise Exception::TypeError, '"zombie" needs to be an integer' if not zombie.integer?
      
      # logging the new event into the database
      @logs.new(:type => "#{from}", :event => "#{event}", :date => Time.now, :hooked_browser_id => zombie).save
      
      # return
      true
    end
    
    private
    @logs
    
  end
end
end
