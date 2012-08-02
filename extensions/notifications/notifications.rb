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

require 'extensions/notifications/channels/tweet'
require 'extensions/notifications/channels/email'

module BeEF
module Extension
module Notifications

  #
  # Notifications class
  #
  class Notifications

    def initialize(from, event, time_now, hb)
      @config = BeEF::Core::Configuration.instance
      if @config.get('beef.extension.notifications.enable') == false
        # notifications are not enabled
        return nil
      else
        @from = from
        @event = event
        @time_now = time_now
        @hb = hb
      end

      username = @config.get('beef.extension.notifications.twitter.target_username')
      to_address    = @config.get('beef.extension.notifications.email.to_address')
      message = "#{from} #{event} #{time_now} #{hb}"

      BeEF::Extension::Notifications::Channels::Tweet.new(username,message)
      BeEF::Extension::Notifications::Channels::Email.new(to_address,message)
    end

  end
  
end
end
end
