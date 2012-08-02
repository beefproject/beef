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
module Core

  class Logger
    
    include Singleton
    
    # Constructor
    def initialize
      @logs = BeEF::Core::Models::Log
      @notifications = BeEF::Extension::Notifications::Notifications
    end
  
    # Registers a new event in the logs
    # @param [String] from The origin of the event (i.e. Authentication, Hooked Browser)
    # @param [String] event The event description
    # @param [Integer] hb The id of the hooked browser affected (default = 0 if no HB)
    # @return [Boolean] True if the register was successful
    def register(from, event, hb = 0)
      # type conversion to enforce standards
      hb = hb.to_i

      # get time now
      time_now = Time.now
      
      # arguments type checking
      raise Exception::TypeError, '"from" needs to be a string' if not from.string?
      raise Exception::TypeError, '"event" needs to be a string' if not event.string?
      raise Exception::TypeError, '"Hooked Browser ID" needs to be an integer' if not hb.integer?
      
      # logging the new event into the database
      @logs.new(:type => "#{from}", :event => "#{event}", :date => time_now, :hooked_browser_id => hb).save

      # if notifications are enabled send the info there too
      @notifications.new(from, event, time_now, hb)
      
      # return
      true
    end
    
    private
    @logs
    
  end
end
end
